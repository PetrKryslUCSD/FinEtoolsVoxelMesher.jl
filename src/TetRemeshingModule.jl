"""
Module For remeshing tetrahedral triangulations.
"""
module TetRemeshingModule

import Base.length
import Base.push!
import Base.getindex
import Base.copy!
import FinEtools.FENodeToFEMapModule: FENodeToFEMap
import FinEtools.MeshTetrahedronModule: T4meshedges
import FinEtools.MeshModificationModule
import FinEtools.MeshModificationModule: interior2boundary
import LinearAlgebra: norm

"""
    _IBuff

This data structure is introduced in order to avoid constant allocation/deallocation of integer  arrays.
The buffer is allocated once and then reused  millions of times. The memory is never  released.
The buffer needs to be accessed  through the methods  below, not directly.
"""
mutable struct _IBuff{IT<:Integer}
    a::Array{IT,1}
    pa::IT
end

function push!(b::IB, i) where {IT, IB<:_IBuff{IT}}
    b.pa = b.pa + 1
    b.a[b.pa] = IT(i)
    return b
end

function empty!(b::IB) where {IT, IB<:_IBuff{IT}}
    b.pa = 0
    return b
end

function trim!(b::IB, i::IT) where {IT, IB<:_IBuff{IT}}
    b.pa = i
    return b
end

length(b::IB) where {IT, IB<:_IBuff{IT}} = b.pa

function getindex(b::IB, i::IT1) where {IT, IB<:_IBuff{IT}, IT1<:Integer}
    @assert i <= length(b)
    return b.a[i]
end

function copyto!(d::IB, s::IB) where {IT, IB<:_IBuff{IT}}
    @assert length(d.a) == length(s.a)
    empty!(d)
    @inbounds for i = 1:length(s) # @inbounds
        push!(d, s.a[i])
    end
    return d
end

function tetvtimes6(vi1::Vector{FT}, vi2::Vector{FT}, vi3::Vector{FT}, vi4::Vector{FT}) where {FT<:Number}
    # local one6th = 1.0/6
    # @assert size(X, 1) == 4
    # @assert size(X, 2) == 3
    @inbounds let
        A1 = vi2[1] - vi1[1]
        A2 = vi2[2] - vi1[2]
        A3 = vi2[3] - vi1[3]
        B1 = vi3[1] - vi1[1]
        B2 = vi3[2] - vi1[2]
        B3 = vi3[3] - vi1[3]
        C1 = vi4[1] - vi1[1]
        C2 = vi4[2] - vi1[2]
        C3 = vi4[3] - vi1[3]
        return ((-A3 * B2 + A2 * B3) * C1 + (A3 * B1 - A1 * B3) * C2 + (-A2 * B1 + A1 * B2) * C3)
    end
end

function _checkvolumes(when, vt, t)
    for i = 1:size(t, 1)
        if any(x -> x == 0, t[i, :])
        else
            if tetvtimes6(vt[:, t[i, 1]], vt[:, t[i, 2]], vt[:, t[i, 3]], vt[:, t[i, 4]]) < 0.0
                error("*** $when Negative volume = $([t[i,:]])")
            end
        end
    end
end

"""
    coarsen(
        t::Array{IT,2},
        inputv::Array{FT,2},
        tmid::Vector{IT};
        bv::Vector{Bool}=Bool[],
        desired_ts=0.0,
        stretch=1.25,
        nblayer=1,
        surface_coarsening=false,
        preserve_thin=false,
        vertex_weight::Vector{FT1}=FT1[],
        edge_length_ratio=1.0,
        reportprogress::F=n -> nothing,
    ) where {IT<:Integer, FT<:Number, F<:Function}

Coarsen a T4 (tetrahedral) mesh.

# Arguments
- `t` = array with vertex numbers, one per tetrahedron in each row
- `v` = array of vertex coordinates, one per vertex in each row
- `tmid` = tetrahedron material identifiers, one per tetrahedron in each row
- Keyword arguments:
    + `bv`=array for all vertices in the input array v.
       Is the vertex on the boundary? True or false. The boundary vertices
       are in layer 1. The vertex layer numbers increase away from
       the boundary,  and the bigger the vertex layer number the bigger
       the mesh size.
    + `desired_ts`=mesh size desired for vertices in layer 1, here mesh size is
       the length of an edge
    + `stretch`=the mesh size should increase by this much within one layer of
        elements, default is 1.25
    + `nblayer`=number of boundary layers where the mesh size should not increase,
        default is 1
    + `surface_coarsening` = is the coarsening intended for the interior or for
       the surface? default is false, which means the default
       is coarsening of the interior.
    + `preserve_thin`= when coarsening the surface, should features which are  thin
       be unaffected by the coarsening? Here thin means consisting of
       only "surface" vertices.
    + `vertex_weight`= weight of vertices, one per  vertex; weight <= 1.0 is ignored,
       but weight>1.0  is used to "stretch" edges connected  to the vertex.
       In this way one may preserve certain edges by assigning  larger
       weight to their vertices. Default is `vertex_weight= []` (which means
       ignore the vertex weights)
    + `edge_length_ratio` = the largest allowed ratio of the lengths of the
       longest and the shortest edge length in the tetrahedron to be produced by
       coarsening(default 1.0). If this is supplied as greater than 1.0, for
       instance 2.0, extra long spikey tetrahedra are prevented.

# Output
`t`, `v`, `tmid` = new arrays for the coarsened grid
"""
function coarsen(
    t::Array{IT,2},
    inputv::Array{FT,2},
    tmid::Vector{IT};
    bv::Vector{Bool}=Bool[],
    desired_ts=0.0,
    stretch=1.25,
    nblayer=1,
    surface_coarsening=false,
    preserve_thin=false,
    vertex_weight::Vector{FT1}=Float64[],
    edge_length_ratio=1.0,
    reportprogress::F=n -> nothing,
) where {IT<:Integer, FT<:Number, FT1<:Number, F<:Function}
    vt = deepcopy(transpose(inputv))  # Better locality of data can be achieved with vertex coordinates in columns
    nv = size(inputv, 1)
    nblayer = IT(nblayer)
    vlayer = IT[]
    if length(bv) == nv
        vlayer = IT[bi == true ? 1 : 0 for bi in bv]
    end
    if vertex_weight !== nothing && length(vertex_weight) != nv
        vertex_weight = ones(FT, nv)
    end
    m = FENodeToFEMap(t, eltype(t)(nv))
    v2t = deepcopy(m.map)# Map vertex to tetrahedron
    e = T4meshedges(t)
    m = FENodeToFEMap(e, eltype(t)(nv))
    v2e = deepcopy(m.map)# Map vertex to edge
    edge_length_ratio_squared = edge_length_ratio^2

    # Figure out the  vertex layer numbers which are the guides to coarsening
    if (isempty(vlayer))
        # # Extract the boundary faces
        f = interior2boundary(t, [1 3 2; 1 2 4; 2 3 4; 1 4 3])
        vlayer = zeros(IT, nv)
        if (surface_coarsening)
            i = setdiff(collect(1:nv), vec(f))
            vlayer[i] .= 1# Mark all vertices in the interior (layer 1)
            vlayer[f] .= 2# Mark all vertices on the boundary (layer 2)
            if (preserve_thin) # thin features should be preserved,
                # mark them as interior (layer 1) so the algorithm does not touch them
                oldvlayer = deepcopy(vlayer)
                for j = vec(f)
                    # is any vertex connected to j  in the interior?
                    connected = false
                    for k = 1:length(v2e[j])
                        if (oldvlayer[e[v2e[j][k], 1]] == 1)
                            connected = true
                            break
                        end
                        if (oldvlayer[e[v2e[j][k], 2]] == 1)
                            connected = true
                            break
                        end
                    end
                    if (!connected)
                        vlayer[j] = 1 # mark it as interior to prevent coarsening
                    end
                end
            end
        else # not (surface_coarsening)
            vlayer[f] .= 1# Mark all vertices on the boundary (layer 1)
            # The remaining (interior) vertices will be numbered below
            # by  distance from the boundary
        end
    end

    # Compute the vertex layer numbers for vertices for which they have not
    # been supplied (which is marked by 0).
    currvlayer = IT(1)
    while true
        # mark layer next to current boundary
        oldvlayer = deepcopy(vlayer)
        for i = 1:size(vlayer, 1)
            if oldvlayer[i] == currvlayer
                for j = 1:length(v2t[i])
                    k = v2t[i][j]
                    for m = 1:4
                        if (oldvlayer[t[k, m]] == 0)
                            vlayer[t[k, m]] = currvlayer + 1
                        end
                    end
                end
            end
        end
        if isempty(findall(p -> p == 0, vlayer)) || (norm(vlayer - oldvlayer) == 0)
            break
        end
        currvlayer += IT(1)
    end
    currvlayer += IT(1)
    # Compute the desired mesh size at a given layer
    desiredes = zeros(FT, currvlayer)
    desiredes[1] = FT(desired_ts)
    for layer in 2:currvlayer
        s = 0
        finalr = 0
        for r = 1:currvlayer
            s = s + stretch^r
            finalr = r
            if (s >= layer - 1)
                break
            end
        end
        finalr = finalr - 1
        desiredes[layer] = desired_ts * stretch^finalr
    end

    

    # Initialize edge lengths, edge vertex counts
    es = _edgelengths(IT.(collect(1:size(e, 1))), vt, e, vertex_weight)
    elayer = IT.(vec(minimum(hcat(vlayer[e[:, 1]], vlayer[e[:, 2]]), dims=2)))
    everfailed = zeros(Bool, size(e, 1))
    minne = IT(200)
    maxne = IT(400)# 36
    availe = _IBuff(zeros(IT, size(e, 1)), zero(IT)) # Flexible  buffer to avoid allocations
    selist = _IBuff(zeros(IT, size(e, 1)), zero(IT)) # Flexible  buffer to avoid allocations

    _checkvolumes("Before reduction starts", vt, t)

    # Let's get down to business
    previouscurrvlayer = IT(0)
    pass = 1
    while true
        availe, currvlayer = _availelist!(availe, selist, elayer, currvlayer, 
            minne, maxne, es, nblayer, desiredes, everfailed)
        if currvlayer != previouscurrvlayer
            reportprogress(currvlayer)
        end
        if (length(availe) == 0)
            break # Done. Hallelujah!
        end
        while true
            selist = _sortedelist!(selist, elayer, es, desiredes, availe)
            Change = false
            for i = 1:length(selist)
                if _collapseedge!(e, es, elayer, vlayer, t, vt, v2t, v2e, vertex_weight, selist[i], edge_length_ratio_squared)
                    Change = true
                    break
                end
                everfailed[selist[i]] = true # the collapse failed for this edge
            end
            if (!Change)
                break
            end
        end
        pass = pass + 1
        previouscurrvlayer = currvlayer
    end
    reportprogress(0) # we are done
    # Note  that we are reverting the transpose of the vertex array here
    _checkvolumes("Before clean", vt, t)
    return _cleanoutput(t, deepcopy(transpose(vt)), tmid)
end

function _collapseedge!(e::Array{IT,2}, es::Vector{FT}, 
    elayer::Vector{IT}, vlayer::Vector{IT}, t::Array{IT,2}, 
    vt::AbstractArray{FT,2}, v2t::Vector{Vector{IT}}, 
    v2e::Vector{Vector{IT}}, vertex_weight::Vector{FT}, 
    dei::IT, edge_length_ratio_squared) where {IT<:Integer, FT<:Number}
    result = false
    # if the operation would result in excessive stretching of an edge, cancel it
    if edge_length_ratio_squared != 1.0
        de1, de2 = e[dei, 1], e[dei, 2]
        if _anyedgetoolong(t, v2t[de2], vt, de2, de1, edge_length_ratio_squared)
            return false # the collapse failed
        end
    end
    # if the operation would result in inverted tetrahedra, cancel it
    de1, de2 = e[dei, 1], e[dei, 2]
    if _anynegvol1(t, v2t[de2], vt, de2, de1)
        de1, de2 = de2, de1# Try the edge the other way
        if _anynegvol1(t, v2t[de2], vt, de2, de1)
            return false # the collapse failed
        end
    end
    vi1 = de1
    vi2 = de2 # the kept Vertex,  and the replaced Vertex
    # Modify t: switch the references to the replaced vertex vi2
    mtl = unique(vcat(v2t[vi1], v2t[vi2]))
    for k = 1:length(mtl)
        for i = 1:4
            if t[mtl[k], i] == vi2
                t[mtl[k], i] = vi1
            end
        end
    end
    # Modify e: switch the references to the replaced vertex vi2
    mel = unique(vcat(v2e[vi1], v2e[vi2]))
    for k = 1:length(mel)
        for i = 1:2
            if e[mel[k], i] == vi2
                e[mel[k], i] = vi1
            end
        end
    end
    # Delete the collapsed tetrahedra from the vertex-to-tet map
    dtl = intersect(v2t[vi1], v2t[vi2]) # list of tets that connect the verts on the collapsed edge
    vl = unique(vec(t[dtl, :])) # vertices incident on the collapsed tetrahedra
    for i = 1:length(vl) # Delete the collapsed tetrahedra
        filter!(p -> !(p in dtl), v2t[vl[i]])
    end
    # Delete edges which are merged by the collapse
    del = v2e[vi2] # vi2 is the vertex that is to be deleted
    for k = 1:length(del)
        i = del[k]
        (e[i, 1] == vi2) ? ov = e[i, 2] : ov = e[i, 1]
        if ov in vl
            e[i, :] .= 0# mark as deleted
            es[i] = Inf# indicate the deleted edge
            elayer[i] = 0# indicate the deleted edge
        end
    end
    t[dtl, :] .= 0# Mark deleted tetrahedra
    e[dei, :] .= 0# Mark deleted edge
    # Update the vertex-2-tet  map
    v2t[vi1] = setdiff(mtl, dtl)
    v2t[vi2] = IT[]# this vertex is gone
    # Update the vertex-2-edge  map
    v2e[vi1] = setdiff(mel, dei)
    v2e[vi2] = IT[]# this vertex is gone
    #     v(vi1,:) = nv1;# new vertex location
    vt[:, vi2] .= Inf# Indicate invalid vertex
    # update edge lengths
    for k = 1:length(v2e[vi1])
        i = v2e[vi1][k]
        if (e[i, 1] == 0)
            es[i] = Inf# indicate the deleted edge
            elayer[i] = 0
        else
            es[i] = _elength(vt, vertex_weight, e[i, 1], e[i, 2])
            elayer[i] = minimum(vlayer[e[i, :]])
        end
    end
    es[dei] = Inf# indicate the deleted edge
    elayer[dei] = 0 # indicate the deleted edge
    return true
end

function _edgelengths(ens::Vector{IT}, vt::AbstractArray{FT,2}, 
    e::Array{IT,2}, vertex_weight::Vector{FT}) where {IT<:Integer, FT<:Number}
    eLengths = zeros(FT, length(ens))
    for i = 1:length(ens)
        en = ens[i]
        eLengths[i] = _elength(vt, vertex_weight, e[en, 1], e[en, 2])
    end
    return eLengths
end

# Weighted length of the edge between 2 vertices
function _elength(vt::AbstractArray{FT,2}, 
    vertex_weight::Vector{FT}, i1::IT, i2::IT) where {IT<:Integer, FT<:Number}
    @inbounds return max(vertex_weight[i1], vertex_weight[i2]) *
                     sqrt((vt[1, i2] - vt[1, i1])^2 + (vt[2, i2] - vt[2, i1])^2 + (vt[3, i2] - vt[3, i1])^2)
end

function _sortedelist!(selist::_IBuff, elayer::Vector{IT}, es::Vector{FT}, 
    desiredes::Vector{FT}, availe::_IBuff) where {IT<:Integer, FT<:Number}
    empty!(selist)
    for i11 = 1:length(availe)
        k11 = availe[i11]
        if (elayer[k11] > 0)
            if es[k11] < desiredes[elayer[k11]]
                push!(selist, k11)
            end
        end
    end
    return selist
end

function _availelist!(availe::_IBuff, selist::_IBuff, elayer::Vector{IT}, 
    currvlayer::IT, minnt::IT, maxnt::IT, es::Vector{FT}, 
    nblayer::IT, desiredes::Vector{FT}, 
    everfailed::Array{Bool,1}) where {IT<:Integer, FT<:Number}
    newcurrvlayer = IT(0)
    empty!(selist)
    for layer = currvlayer:-1:nblayer+1 # This can be changed to allow for more or less coarsening
        empty!(availe)
        @inbounds for i = 1:length(elayer) # @inbounds
            if (layer <= elayer[i]) && (!everfailed[i])
                push!(availe, i)
            end
        end
        selist = _sortedelist!(selist, elayer, es, desiredes, availe)
        newcurrvlayer = layer
        if (length(selist) >= minnt)
            break
        end
    end
    return copyto!(availe, trim!(selist, min(length(selist), maxnt))), IT(newcurrvlayer)
end

function _anynegvol1(t::Array{IT,2}, whichtets::Vector{IT}, 
    vt::AbstractArray{FT,2}, whichv::IT, otherv::IT) where {IT<:Integer, FT<:Number}
    for iS1 in whichtets
        i1, i2, i3, i4 = t[iS1, :] # nodes of the tetrahedron
        if (i1 == whichv)
            i1 = otherv
        end
        if (i2 == whichv)
            i2 = otherv
        end
        if (i3 == whichv)
            i3 = otherv
        end
        if (i4 == whichv)
            i4 = otherv
        end
        if tetvtimes6(vt[:, i1], vt[:, i2], vt[:, i3], vt[:, i4]) < 0.0
            return true
        end
    end
    return false
end

function _anyedgetoolong(t::Array{IT,2}, whichtets::Vector{IT}, 
    vt::AbstractArray{FT,2}, whichv::IT, otherv::IT, 
    edge_length_ratio_squared) where {IT<:Integer, FT<:Number}
    for iS1 in whichtets
        i1, i2, i3, i4 = t[iS1, :] # nodes of the tetrahedron
        if (i1 == whichv)
            i1 = otherv
        end
        if (i2 == whichv)
            i2 = otherv
        end
        if (i3 == whichv)
            i3 = otherv
        end
        if (i4 == whichv)
            i4 = otherv
        end
        if !(i1 == i2 || i2 == i3 || i1 == i3 || i2 == i4 || i1 == i4 || i4 == i3)
            # only if all vertices are distinct
            ls = _tsqedgelengths(vt[:, i1], vt[:, i2], vt[:, i3], vt[:, i4])
            minl = min(ls...)
            maxl = max(ls...)
            if maxl > edge_length_ratio_squared * minl
                return true
            end
        end
    end
    return false
end


function _tsqedgelengths(vi1::Vector{FT}, vi2::Vector{FT}, vi3::Vector{FT}, vi4::Vector{FT}) where {FT<:Number}
    @inbounds LA = let
        A1 = vi2[1] - vi1[1]
        A2 = vi2[2] - vi1[2]
        A3 = vi2[3] - vi1[3]
        A1^2 + A2^2 + A3^2
    end
    @inbounds LB = let
        A1 = vi2[1] - vi3[1]
        A2 = vi2[2] - vi3[2]
        A3 = vi2[3] - vi3[3]
        A1^2 + A2^2 + A3^2
    end
    @inbounds LC = let
        A1 = vi1[1] - vi3[1]
        A2 = vi1[2] - vi3[2]
        A3 = vi1[3] - vi3[3]
        A1^2 + A2^2 + A3^2
    end
    @inbounds LD = let
        A1 = vi1[1] - vi4[1]
        A2 = vi1[2] - vi4[2]
        A3 = vi1[3] - vi4[3]
        A1^2 + A2^2 + A3^2
    end
    @inbounds LE = let
        A1 = vi2[1] - vi4[1]
        A2 = vi2[2] - vi4[2]
        A3 = vi2[3] - vi4[3]
        A1^2 + A2^2 + A3^2
    end
    @inbounds LF = let
        A1 = vi3[1] - vi4[1]
        A2 = vi3[2] - vi4[2]
        A3 = vi3[3] - vi4[3]
        A1^2 + A2^2 + A3^2
    end
    return LA, LB, LC, LD, LE, LF
end


function _cleanoutput(t::Array{IT,2}, v::Array{FT,2}, tmid::Array{IT,1}) where {IT<:Integer, FT<:Number}
    nn = zeros(Int, size(v, 1))
    nv = deepcopy(v)
    k = 1
    for i = 1:size(v, 1)
        if (v[i, 1] != Inf) # Is this an active vertex?
            nn[i] = k
            nv[k, :] = v[i, :]
            k = k + 1
        end
    end
    nnv = k - 1
    v = nv[1:nnv, :]
    # delete connectivities of collapsed tetrahedra, and renumber nodes
    nt = deepcopy(t)
    fill!(nt, 0)
    ntmid = deepcopy(tmid)
    fill!(ntmid, 0)
    k = 1
    for i = 1:size(t, 1)
        if (t[i, 1] != 0)# not deleted
            if (!isempty(findall(p -> p == 0, nn[t[i, :]])))
                # error('Referring to deleted vertex')
                t[i, :] .= 0
            else
                j = nn[t[i, :]]
                nt[k, :] = j
                ntmid[k] = tmid[i]
                k = k + 1
            end
        end
    end
    t = nt[1:k-1, :]

    # delete unconnected vertices
    uv = unique(vec(t))
    if (length(uv) != size(v, 1)) # there may be unconnected vertices
        nn = zeros(Int, size(v, 1), 1)
        nn[uv] = collect(1:length(uv))
        nv = deepcopy(v)
        for i = 1:size(v, 1)
            if (nn[i] != 0)
                nv[nn[i], :] = v[i, :]
            end
        end
        v = nv[1:length(uv), :]
        for i = 1:size(t, 1)
            t[i, :] = nn[t[i, :]]
        end
    end
    # these are the material IDs
    tmid = ntmid[1:k-1]
    # Are there any duplicated tetrahedra? Here is how that can happen: consider
    # to tetrahedra that share a face. Tetrahedron 1, a,b,c,d, and tetrahedron
    # 2, a,c,b,e. Let us consider the face a,b,c to be in the x-y plane. Now
    # collapse the edge d,e. This will lead to those 2 tetrahedra becoming one. 
    # 
    uti = MeshModificationModule._myunique2index(t)
    t = t[uti, 1:4]
    tmid = tmid[uti]
    return t, v, tmid
end

end # module
