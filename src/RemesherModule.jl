"""
    RemesherModule

Module for remeshing of tetrahedral meshes.
"""
module RemesherModule

using FinEtools.FTypesModule: FInt, FFlt, FCplxFlt, FFltVec, FIntVec, FFltMat, FIntMat, FMat, FVec, FDataDict
import FinEtools.MeshTetrahedronModule: T4voximg, tetv, T4meshedges
import FinEtools.FESetModule: connasarray
import FinEtools.MeshModificationModule: interior2boundary, vertexneighbors, smoothertaubin
import ..TetRemeshingModule: coarsen
import LinearAlgebra: norm
import Statistics: mean

mutable struct  ElementSizeWeightFunction
    influenceweight::FFlt
    center::Vector{FFlt}
    influenceradius::FFlt
end

function weight(self::ElementSizeWeightFunction, xyz::Vector{FFlt})
    r = norm(xyz - self.center);
    return 1.0+(self.influenceweight)*(1.0-1.0/(1+exp(-3*(4.0*r/self.influenceradius-3))));
end

"""
    Remesher{CoordT,DataT}

Tetrahedral image mesher.
"""
mutable struct Remesher
    currentelementsize::FFlt
    elementsizeweightfunctions::Vector{ElementSizeWeightFunction}
    t::Array{Int64, 2}
    v::Array{FFlt, 2}
    tmid::Vector{Int64}
end

function Remesher(v, t, tmid, currentelementsize) 
    if currentelementsize == 0.0
        e = T4meshedges(t);
        el = [norm(v[e[i,1], :]-v[e[i,2], :]) for i in 1:size(e, 1)] 
        currentelementsize = mean(el)
    end
    return Remesher(currentelementsize, ElementSizeWeightFunction[], deepcopy(t), deepcopy(v), deepcopy(tmid))
end

function setelementsizeweightfunctions(self::Remesher, e)
    self.elementsizeweightfunctions = deepcopy(e)
end

function evaluateweights(self::Remesher)
    vertex_weight = ones(FFlt, size(self.v,1));
    if !isempty(self.elementsizeweightfunctions)
        for i = 1:size(self.v,1)
            vertex_weight[i] = 1.0
            for jewf=1:length(self.elementsizeweightfunctions)
                vertex_weight[i] = max(vertex_weight[i], weight(self.elementsizeweightfunctions[jewf], vec(self.v[i, :])))
            end
        end
    end
    return vertex_weight;
end

function coarsenvolume!(self::Remesher, desired_element_size::FFlt)
    vertex_weight = evaluateweights(self)
    self.t, self.v, self.tmid = coarsen(self.t, self.v, self.tmid; surface_coarsening = false, desired_ts = desired_element_size, vertex_weight = vertex_weight);
    return self;
end

function coarsensurface!(self::Remesher, desired_element_size::FFlt)
    vertex_weight = evaluateweights(self)
    self.t, self.v, self.tmid = coarsen(self.t, self.v, self.tmid; surface_coarsening = true, desired_ts = desired_element_size, vertex_weight = vertex_weight);
    return self;
end

function volumes!(V::Array{FFlt, 1}, v::Array{FFlt, 2}, t::Array{Int, 2})
    for i = 1:size(t, 1)
        v11, v12, v13 = v[t[i, 1], :]
        v21, v22, v23 = v[t[i, 2], :]
        v31, v32, v33 = v[t[i, 3], :]
        v41, v42, v43 = v[t[i, 4], :]
        V[i] = tetv(v11, v12, v13, v21, v22, v23, v31, v32, v33, v41, v42, v43)
    end
    return V
end

function allnonnegativevolumes(v, t)
    for i = 1:size(t, 1)
        v11, v12, v13 = v[t[i, 1], :]
        v21, v22, v23 = v[t[i, 2], :]
        v31, v32, v33 = v[t[i, 3], :]
        v41, v42, v43 = v[t[i, 4], :]
        if tetv(v11, v12, v13, v21, v22, v23, v31, v32, v33, v41, v42, v43) < 0.0
             return false
        end
    end
    return true
end

function smooth!(self::Remesher, npass::Int = 5)
    if !allnonnegativevolumes(self.v, self.t) # This test is not strictly necessary,  just  while the remeshing procedure is in flux
        error("shouldn't be here")
    end
    V = zeros(size(self.t, 1)) # tetrahedron volumes

    # Find boundary vertices
    bv = falses(size(self.v, 1));
    f = interior2boundary(self.t, [1 3 2; 1 2 4; 2 3 4; 1 4 3])

    # find neighbors for the SURFACE vertices
    fvn = vertexneighbors(f, size(self.v, 1));
    # Smoothing considering only surface connections
    fv = FFltMat[]
    trialfv = deepcopy(self.v)
    for pass = 1:npass
        fv =  smoothertaubin(trialfv, fvn, bv, 1, 0.5, -0.5);
        V = volumes!(V, fv, self.t)
        for i = 1:length(V)
            if V[i] < 0.0 # smoothing is only allowed if it results in non-negative volume
                c = self.t[i, :]
                fv[c, :] = trialfv[c, :]# undo the smoothing
            end
        end
        copyto!(trialfv, fv)
    end

    # find neighbors for the VOLUME vertices
    vn =  vertexneighbors(self.t, size(self.v, 1));
    # Smoothing considering all connections through the volume
    bv[vec(f)] .= true;
    v = FFltMat[]
    trialv = deepcopy(fv)
    for pass = 1:npass
        v = smoothertaubin(trialv, vn, bv, 1, 0.5, -0.5);
        anynegative = true; chk=1
        while anynegative
            # println("Checking volumes $chk")
            V = volumes!(V, v, self.t)
            anynegative = false
            for i = 1:length(V)
                if V[i] < 0.0 # smoothing is only allowed if it results in non-negative volume
                    c = self.t[i, :]
                    v[c, :] = self.v[c, :]# undo the smoothing
                    anynegative = true
                end
            end
            chk = chk+1
        end
        copyto!(trialv, v)
    end

    if !allnonnegativevolumes(v, self.t) # This test is not strictly necessary,  just  while the remeshing procedure is in flux
        error("shouldn't be here")
    end

    copyto!(self.v, v) # save the final result
    return self
end

"""
    remesh!(self::Remesher, stretch::FFlt = 1.2)

Perform a remeshing step.

A coarsening sequence of coarsen surface -> smooth -> coarsen volume -> smooth
is performed.

After meshing the vertices, tetrahedra, and material identifiers,  can be retrieved
as `t, v, tmid = meshdata(remesher)`.
"""
function remesh!(self::Remesher, stretch::FFlt = 1.2)
    coarsensurface!(self, sqrt(1.0)*self.currentelementsize)
    smooth!(self);
    coarsenvolume!(self, sqrt(2.0)*self.currentelementsize);
    smooth!(self);
    self.currentelementsize = stretch * self.currentelementsize
    return self
end

function meshdata(self::Remesher)
    return self.t, self.v, self.tmid
end

"""
    volumes(self::Remesher)

Compute tetrahedral volumes in the current mesh.
"""
function volumes(self::Remesher)
    V = zeros(size(self.t, 1))
    return volumes!(V, self.v, self.t)
end

end
