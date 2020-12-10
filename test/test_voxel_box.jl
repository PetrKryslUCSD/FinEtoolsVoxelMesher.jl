module mmmvvoxelmm1
using FinEtools
using FinEtoolsVoxelMesher
using Test
function test()
    V = VoxelBoxVolume(Int, 5*[5,6,7], [4.0, 4.0, 5.0])

    s1 = solidsphere((1.5, 2.0, 2.0), 1.3)
    s2 = solidsphere((1.5, 1.0, 2.0), 1.3)
    fillsolid!(V, differenceop(s1, s2), 1)

    File = "mmmvvoxelmm1.vtk"
    vtkexport(File, V)
    # @async run(`"paraview.exe" $File`)
    try rm(File) catch end

    @test (V.data[15,13,12]==0)
    @test (V.data[15,16,15]==1)
end
end
using .mmmvvoxelmm1
mmmvvoxelmm1.test()

module mmmvvoxelmm2
using FinEtools
using FinEtoolsVoxelMesher
using Test
function test()
    V = VoxelBoxVolume(Int, 5*[5,6,7], [4.0, 4.0, 5.0])

    b1 = solidbox((0.0, 0.0, 0.0), (1.0, 4.0, 5.0))
    b2 = solidbox((0.0, 0.0, 0.0), (4.0, 1.0, 5.0))
    fillsolid!(V, unionop(b1, b2), 1)

    File = "mmmvvoxelmm2.vtk"
    vtkexport(File, V)
    # @async run(`"paraview.exe" $File`)
    try rm(File) catch end

    # println("$(V.data[15,13,12])")
    # println("$(V.data[1,1,12])")
    @test (V.data[15,13,12]==0)
    @test (V.data[1,1,12]==1)
end
end
using .mmmvvoxelmm2
mmmvvoxelmm2.test()

module mmmvvoxelmm3
using FinEtools
using FinEtoolsVoxelMesher
using Test
function test()
    V = VoxelBoxVolume(Int, 15*[5,6,7], [4.0, 4.0, 5.0])

    b1 = solidbox((0.0, 0.0, 0.0), (1.0, 4.0, 5.0))
    b2 = solidbox((0.0, 0.0, 0.0), (4.0, 1.0, 5.0))
    fillsolid!(V, unionop(b1, b2), 1)
    s2 = solidsphere((2.0, 2.0, 2.5), 1.0)
    fillsolid!(V, s2, 2)


    File = "mmmvvoxelmm3.vtk"
    vtkexport(File, V)
    # @async run(`"paraview.exe" $File`)
    try rm(File) catch end

    # println("$(V.data[15,13,12])")
    # println("$(V.data[1,1,12])")
    # @test (V.data[15,13,12]==0)
    # @test (V.data[1,1,12]==1)
end
end
using .mmmvvoxelmm3
mmmvvoxelmm3.test()


module mmmvvoxelmm4
using FinEtools
using FinEtoolsVoxelMesher
using Test
function test()
    V = VoxelBoxVolume(Int, 5*[5,6,7], [4.0, 4.0, 5.0])

    h1 = solidcylinder((2.0, 2.0, 2.5), (1.0, 0.0, 0.0), 0.5)
    fillsolid!(V, h1, 1)


    File = "mmmvvoxelmm4.vtk"
    vtkexport(File, V)
    # @async run(`"paraview.exe" $File`)
    try rm(File) catch end

    # println("$(V.data[15,13,12])")
    # println("$(V.data[1,15,12])")
    # println("$(V.data[13,15,20])")
    @test (V.data[15,13,12]==0)
    @test (V.data[1,15,12]==0)
    @test (V.data[13,15,20]==1)
end
end
using .mmmvvoxelmm4
mmmvvoxelmm4.test()


module mmmvvoxelmm5
using FinEtools
using FinEtoolsVoxelMesher
using Test
function test()
    V = VoxelBoxVolume(Int, 15*[5,6,7], [4.0, 4.0, 5.0])

    b1 = solidbox((0.0, 0.0, 0.0), (1.0, 4.0, 5.0))
    b2 = solidbox((0.0, 0.0, 0.0), (4.0, 1.0, 5.0))
    h1 = solidcylinder((2.0, 3.0, 2.5), (1.0, 0.0, 0.0), 0.5)
    fillsolid!(V, differenceop(unionop(b1, b2), h1), 1)

    s2 = solidsphere((2.0, 2.0, 2.5), 1.0)
    fillsolid!(V, s2, 2)


    File = "mmmvvoxelmm5.vtk"
    vtkexport(File, V)
    # @async run(`"paraview.exe" $File`)
    try rm(File) catch end

    # println("$(V.data[15,13,12])")
    # println("$(V.data[1,35,12])")
    # println("$(V.data[35,45,50])")
    @test (V.data[15,13,12]==1)
    @test (V.data[1,35,12]==1)
    @test (V.data[35,45,50]==2)
end
end
using .mmmvvoxelmm5
mmmvvoxelmm5.test()

module mmmvvoxelmm6
using FinEtools
using FinEtoolsVoxelMesher
using Test
function test()
    raw = zeros(UInt8, 13, 14, 15)
    raw[5:7, 2:13, 12:14] .= 1
    V = VoxelBoxVolume(raw, [4.0, 4.0, 5.0])

    File = "mmmvvoxelmm6.vtk"
    vtkexport(File, V)
    # @async run(`"paraview.exe" $File`)
    try rm(File) catch end

    # println("$(V.data[7,13,12])")
    # println("$(V.data[1,12,12])")
    # println("$(V.data[12,10,5])")
    @test (V.data[7,13,12]==1)
    @test (V.data[1,12,12]==0)
    @test (V.data[12,10,5]==0)
end
end
using .mmmvvoxelmm6
mmmvvoxelmm6.test()

module mmmvvoxelmm7
using FinEtools
using FinEtoolsVoxelMesher
using Test
function test()
    raw = zeros(UInt8, 13, 14, 15)
    V = VoxelBoxVolume(raw, [4.0, 4.0, 5.0])
    fillvolume!(V, 2)
    V.data[5:7, 2:13, 12:14] .= 1

    File = "mmmvvoxelmm7.vtk"
    vtkexport(File, V)
    # @async run(`"paraview.exe" $File`)
    try rm(File) catch end

    # println("$(V.data[7,13,12])")
    # println("$(V.data[1,12,12])")
    # println("$(V.data[12,10,5])")
    @test (V.data[7,13,12]==1)
    @test (V.data[1,12,12]==2)
    @test (V.data[12,10,5]==2)
end
end
using .mmmvvoxelmm7
mmmvvoxelmm7.test()

module mmmvvoxelmm8
using FinEtools
using FinEtoolsVoxelMesher
using Test
function test()
    raw = zeros(UInt8, 13, 14, 15)
    V = VoxelBoxVolume(raw, [4.0, 4.0, 5.0])
    V.data[5:7, 2:13, 12:14] .= 1
    Vt = trim(V, 0)
    @test size(Vt) == (3, 12, 3)
    @test size(V, 3) == 15
    Vtt = trim(Vt, 0)
    @test size(Vtt) == (3, 12, 3)

    File = "mmmvvoxelmm8.vtk"
    vtkexport(File, V)
    # @async run(`"paraview.exe" $File`)
    try rm(File) catch end
end
end
using .mmmvvoxelmm8
mmmvvoxelmm8.test()

module mmmvvoxelmm9
using FinEtools
using FinEtoolsVoxelMesher
using Test
function test()
    raw = zeros(UInt8, 13, 14, 15)
    fill!(raw, 2)
    V = VoxelBoxVolume(raw, [4.0, 4.0, 5.0])
    V.data[5:7, 2:13, 12:14] .= 1
    Vt = trim(V, 2)
    Vp = pad(Vt, (4, 6), (1, 1), (11, 1), 0)
    @test size(V) == size(Vp)
    @test size(Vt) == (3, 12, 3)
    @test size(V, 3) == 15
    Vtt = trim(Vt, 0)
    @test size(Vtt) == (3, 12, 3)

    # File = "mmmvvoxelmm9.vtk"
    # vtkexport(File, V)
    # # @async run(`"paraview.exe" $File`)
    # try rm(File) catch end

    # println("$(V.data[7,13,12])")
    # println("$(V.data[1,12,12])")
    # println("$(V.data[12,10,5])")
    # @test (V.data[7,13,12]==1)
    # @test (V.data[1,12,12]==2)
    # @test (V.data[12,10,5]==2)
end
end
using .mmmvvoxelmm9
mmmvvoxelmm9.test()

module mvoxelmm12
using FinEtools
using FinEtoolsVoxelMesher
using Test
function test()
    V = VoxelBoxVolume(Int, 5*[5,6,7], [4.0, 4.0, 5.0])

    b1 = solidbox((0.0, 0.0, 0.0), (1.0, 4.0, 5.0))
    b2 = solidbox((0.0, 0.0, 0.0), (4.0, 1.0, 5.0))
    fillsolid!(V, unionop(b1, b2), 2)
    fillsolid!(V, complementop(unionop(b1, b2)), 1)

    File = "mvoxelmm12.vtk"
    vtkexport(File, V)
    # @async run(`"paraview.exe" $File`)
    try rm(File) catch end

    # println("$(V.data[15,13,12])")
    # println("$(V.data[1,1,12])")
    @test (V.data[15,13,12]==1)
    @test (V.data[1,1,12]==2)
end
end
using .mvoxelmm12
mvoxelmm12.test()

module mvoxelmm13
using FinEtools
using FinEtoolsVoxelMesher
using Test
function test()
    V = VoxelBoxVolume(Int, 7*[5,6,7], [4.0, 4.0, 5.0])

    for k = 1:size(V, 3)
        for j = 1:size(V, 2)
            for i = 1:size(V, 1)
                V.data[i, j, k] = 35^2-(i^2+j^2+k^2)
            end
        end
    end

    threshold_value, voxel_below, voxel_above = 20, 1, 0
    V = threshold(V, threshold_value, voxel_below, voxel_above)

    # File = "mvoxelmm13.vtk"
    # vtkexport(File, V)
    # @async run(`"paraview.exe" $File`)
    # try rm(File) catch end

    # println("$(V.data[15,13,12])")
    # println("$(V.data[1,1,12])")
    # @test (V.data[15,13,12]==1)
    @test (V.data[1,1,1]==0)
    @test (V.data[end,end,end] != 0)
end
end
using .mvoxelmm13
mvoxelmm13.test()


module mmbracketmm
using FinEtools
using FinEtoolsVoxelMesher
using Test
function test()

    V = VoxelBoxVolume(Int, 6*[5,6,7], [4.0, 4.0, 5.0])

    b1 = solidbox((0.0, 0.0, 0.0), (1.0, 4.0, 5.0))
    b2 = solidbox((0.0, 0.0, 0.0), (4.0, 1.0, 5.0))
    h1 = solidcylinder((2.0, 2.5, 2.5), (1.0, 0.0, 0.0), 00.75)
    fillsolid!(V, differenceop(unionop(b1, b2), h1), 1)

    fens, fes = H8voximg(V.data, vec([voxeldims(V)...]), [1])
    fens = meshsmoothing(fens, fes; npass = 5)
    # println("count(fes) = $(count(fes))")
    @test count(fes) == 16337

    File = "voxel_bracket_mesh.vtk"
    vtkexportmesh(File, fens, fes)
    # @async run(`"paraview.exe" $File`)
    try rm(File) catch end
end
end
using .mmbracketmm
mmbracketmm.test()


module mmmbbracketmtet1
using FinEtools
using FinEtoolsVoxelMesher
using Test
function test()

    V = VoxelBoxVolume(Int, 6*[5,6,7], [4.0, 4.0, 5.0])

    b1 = solidbox((0.0, 0.0, 0.0), (1.0, 4.0, 5.0))
    b2 = solidbox((0.0, 0.0, 0.0), (4.0, 1.0, 5.0))
    h1 = solidcylinder((2.0, 2.5, 2.5), (1.0, 0.0, 0.0), 00.75)
    fillsolid!(V, differenceop(unionop(b1, b2), h1), 1)

    fens, fes = T4voximg(V.data, vec([voxeldims(V)...]), [1])
    fens = meshsmoothing(fens, fes; method = :laplace, npass = 5)
    # println("count(fes) = $(count(fes))")
    @test count(fes) == 81685
end
end
using .mmmbbracketmtet1
mmmbbracketmtet1.test()

module mmmremeshingm1m
using FinEtools
using FinEtoolsVoxelMesher
using Test
function test()
    V = VoxelBoxVolume(Int, 8*[5,6,7], [4.0, 4.0, 5.0])

    b1 = solidbox((0.0, 0.0, 0.0), (1.0, 4.0, 5.0))
    b2 = solidbox((0.0, 0.0, 0.0), (4.0, 1.0, 5.0))
    h1 = solidcylinder((2.0, 2.5, 2.5), (1.0, 0.0, 0.0), 0.75)
    fillsolid!(V, differenceop(unionop(b1, b2), h1), 1)

    im = ImageMesher(V, zero(eltype(V.data)), eltype(V.data)[1])
    # println("Mesh size: initial = $(size(im.t,1))")
    # fens = FENodeSet(im.v)
    # fes = FESetT4(im.t)
    # setlabel!(fes, im.tmid)
    # File = "voxel_bracket_mesh_tet.vtk"
    # vtkexportmesh(File, fens, fes)
    # @async run(`"paraview.exe" $File`)
    setelementsizeweightfunctions(im.remesher, [ElementSizeWeightFunction(20.0, vec([0.0, 2.5, 2.5]), 1.0), ElementSizeWeightFunction(1.0, vec([0.0, 2.5, 2.5]), 3.5)])
    remesh!(im)
    updatecurrentelementsize!(im, 1.2*currentelementsize(im))
    # println("Mesh size: final = $(size(im.t,1))")
    t, v, tmid = meshdata(im.remesher)
    @test (size(t,1) - 113857.)/113857 <= 0.0013
    fens = FENodeSet(v)
    fes = FESetT4(t)
    setlabel!(fes, tmid)

    # File = "voxel_bracket_mesh_tet.vtk"
    # vtkexportmesh(File, fens, fes)
    # @async run(`"paraview.exe" $File`)
end
end
using .mmmremeshingm1m
mmmremeshingm1m.test()

module mmvoxel_bracket_mesh
using FinEtools
using FinEtoolsVoxelMesher
using FinEtoolsVoxelMesher.TetRemeshingModule: tetvtimes6
using FinEtools.MeshExportModule
using Test
function checkvolumes(when, vt, t)
    if size(vt, 1) < maximum(t[:])
        error("*** $when Wrong number of vertices")
    end
    vt = transpose(deepcopy(vt))
    for i = 1:size(t, 1)
        if any(x->x==0, t[i,:])
            @warn "t[$i,:] = $(t[i,:])"
        else
            if tetvtimes6(vt[:,t[i,1]], vt[:,t[i,2]], vt[:,t[i,3]], vt[:,t[i,4]]) < 0.0
                error("*** $when Negative volume = $([t[i,:]])")
            end
        end
    end
end
function test()
    V = VoxelBoxVolume(Int, 8*[5,6,7], [4.0, 4.0, 5.0])

    b1 = solidbox((0.0, 0.0, 0.0), (1.0, 4.0, 5.0))
    b2 = solidbox((0.0, 0.0, 0.0), (4.0, 1.0, 5.0))
    h1 = solidcylinder((2.0, 2.5, 2.5), (1.0, 0.0, 0.0), 0.75)
    fillsolid!(V, differenceop(unionop(b1, b2), h1), 1)

    im = ImageMesher(V, zero(eltype(V.data)), eltype(V.data)[1])
    t, v, tmid = meshdata(im.remesher)
    t, v, tmid = meshdata(im)
    checkvolumes("test", v, t)
    # println("Mesh size: initial = $(size(im.t,1))")
    fens = FENodeSet(v)
    fes = FESetT4(t)
    setlabel!(fes, tmid)
    File = "voxel_bracket_mesh_tet.vtk"
    vtkexportmesh(File, fens, fes)

    @test size(t,1) == 196275

    setelementsizeweightfunctions(im.remesher, [ElementSizeWeightFunction(20.0, vec([0.0, 2.5, 2.5]), 1.0), ElementSizeWeightFunction(1.0, vec([0.0, 2.5, 2.5]), 3.5)])
    for i = 1:12
        #println("Phase $i");
        t, v, tmid = meshdata(im.remesher)
        checkvolumes("test", v, t)
        remesh!(im)
        updatecurrentelementsize!(im, 1.1*currentelementsize(im))
        t, v, tmid = meshdata(im.remesher)
        checkvolumes("test", v, t)
        #println("Mesh size: final = $(size(im.t,1))")
        # V = volumes(im.remesher)
        # @test length(findall(x -> x <= 0.0, V)) == 0
        # println("length(find(x -> x <= 0.0, V)) = $(length(find(x -> x <= 0.0, V)))")
        # open("im$(i)" * ".jls", "w") do file
        #     serialize(file, im)
        # end
    end

    t, v, tmid = meshdata(im.remesher)
    fens = FENodeSet(v)
    fes = FESetT4(t)
    setlabel!(fes, tmid)
    #println("count(fes) = $(count(fes))")
    @test abs(count(fes) - 15253) / 15253 <= 0.004

    # bfes = meshboundary(fes)
    # list = selectelem(fens, fes; overlappingbox = boundingbox([0.2018 2.1537 3.9064]), inflate = 0.01, allin = false)
    # File = "voxel_bracket_mesh_tet.vtk"
    # vtkexportmesh(File, fens, subset(fes, list))
    # @async run(`"paraview.exe" $File`)
    File = "voxel_bracket_mesh_tet.vtk"
    vtkexportmesh(File, fens, fes)
    #@async run(`"paraview.exe" $File`)
    try rm(File); catch end

    ne = NASTRANExporter("voxel_bracket_mesh_tet.nas")
    BEGIN_BULK(ne)
    for i = 1:count(fens)
        GRID(ne, i, fens.xyz[i, :])
    end
    for i = 1:count(fes)
        CTETRA(ne, i, 1, [fes.conn[i]...])
    end
    PSOLID(ne, 1, 1)
    MAT1(ne, 1, 20.0e9, 0.3, 1800.0)
    ENDDATA(ne)
    close(ne)
    try rm(ne.filename); catch end

    stle = STLExporter("voxel_bracket_mesh_tet.stl")
    solid(stle)
    bfes = meshboundary(fes)
    for i = 1:count(bfes)
        facet(stle, fens.xyz[bfes.conn[i][1], :], fens.xyz[bfes.conn[i][2], :], fens.xyz[bfes.conn[i][3], :])
    end
    endsolid(stle)
    close(stle)
    try rm(stle.filename); catch end
end
end
using .mmvoxel_bracket_mesh
mmvoxel_bracket_mesh.test()


module mrremeshing1
using FinEtools
using FinEtools.MeshExportModule
using FinEtoolsVoxelMesher
using FinEtoolsVoxelMesher.TetRemeshingModule: coarsen
using Test
function test()
    L= 0.3;
    W = 0.3;
    a = 0.15;
    nL=46; nW=46; na=36;

    fens,fes = T4block(a,L,W,nL,nW,na,:a);
    t = connasarray(fes);
    v = deepcopy(fens.xyz);
    tmid = ones(Int, size(t,1));

    desired_ts =a;
    bfes = meshboundary(fes);
    f = connectednodes(bfes);
    bv = zeros(Bool, size(v,1));
    bv[f] .= true;

    # println("Mesh size: initial = $(size(t,1))")
    t0 = time()

    t, v, tmid = coarsen(t, v, tmid; bv = bv, desired_ts = desired_ts);

    # println("Mesh size: final = $(size(t,1)) [$(time() - t0) sec]")
    @test size(t,1) == 75102

    fens.xyz = deepcopy(v)
    fes = fromarray!(fes, t)
    setlabel!(fes, tmid)
    geom  =  NodalField(fens.xyz)

    femm  =  FEMMBase(IntegDomain(fes, SimplexRule(3, 1)))
    V = integratefunction(femm, geom, (x) ->  1.0)
    # println("V = $(V) compared to $(L * W * a)")
    @test abs(V - L * W * a)/V < 1.0e-3
    # File = "test1.vtk"
    # MeshExportModule.vtkexportmesh(File, t, v, MeshExportModule.T4)
    # @async run(`"paraview.exe" $File`)
end
end
using .mrremeshing1
mrremeshing1.test()
