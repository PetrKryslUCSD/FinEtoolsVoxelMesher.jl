module m_flint_mesh
using FinEtools
using FinEtoolsVoxelMesher
using FinEtools.MeshExportModule
using FinEtools.MeshImportModule
using Test

function test()
   output = MeshImportModule.import_ABAQUS("./flint-rock3-1_5mm.inp")
   fens, fes = output["fens"], output["fesets"][1]
   fens.xyz .*= phun("MM")

   # println("Before unrefinement: ")
   # println("Number of nodes: $(count(fens))")
   # println("Interior mesh: $(count(fes)) tets")
   # println("Surface mesh: $(count(meshboundary(fes))) triangles")

   # File = "Original.vtk"
   # vtkexportmesh(File, fens, fes)
   # @async run(`"paraview.exe" $File`)

   remesher = Remesher(fens.xyz, connasarray(fes), [1 for idx in 1:count(fes)], 0.0)
   for pass in 1:4
        remesh!(remesher)
        updatecurrentelementsize!(remesher, 1.2*currentelementsize(remesher))
        t, v, tmid = meshdata(remesher)
        #@show size(v, 1)
        #fens.xyz = v
        fes = fromarray!(fes, t)
        setlabel!(fes, tmid)
        # File = "Unref-$(pass).vtk"
        # vtkexportmesh(File, fens, fes)
        # println("After unrefinement: ")
        # println("Number of nodes: $(count(fens))")
        # println("Interior mesh: $(count(fes)) tets")
        # println("Surface mesh: $(count(meshboundary(fes))) triangles")
    end
    t, v, tmid = meshdata(remesher)
    fens.xyz = v;
    fes = fromarray!(fes, t)
    setlabel!(fes, tmid)
    vtkexportmesh("sample1.vtk", fens, fes);
    # @show length(tmid)
    @test abs(length(tmid) - 4954) / length(tmid) < 0.05
    #@test length(tmid) == 4954 # with 1.5.3
    true
end
end
using .m_flint_mesh
m_flint_mesh.test()

module m_flint_mesh_2
using FinEtools
using FinEtoolsVoxelMesher
using FinEtools.MeshExportModule
using FinEtools.MeshImportModule
using Test

function test()
   output = MeshImportModule.import_ABAQUS("./flint-rock3-1_5mm.inp")
   fens, fes = output["fens"], output["fesets"][1]
   fens.xyz .*= phun("MM")

   # println("Before unrefinement: ")
   # println("Number of nodes: $(count(fens))")
   # println("Interior mesh: $(count(fes)) tets")
   # println("Surface mesh: $(count(meshboundary(fes))) triangles")

   # File = "Original.vtk"
   # vtkexportmesh(File, fens, fes)
   # @async run(`"paraview.exe" $File`)

   remesher = Remesher(fens.xyz, connasarray(fes), [1 for idx in 1:count(fes)], 0.0)
   for pass in 1:13
        remesh!(remesher, 3.0)
        updatecurrentelementsize!(remesher, 1.2*currentelementsize(remesher))
        t, v, tmid = meshdata(remesher)
        #@show size(v, 1)
        #fens.xyz = v
        fes = fromarray!(fes, t)
        setlabel!(fes, tmid)
        # File = "Unref-$(pass).vtk"
        # vtkexportmesh(File, fens, fes)
        # println("After unrefinement: ")
        # println("Number of nodes: $(count(fens))")
        # println("Interior mesh: $(count(fes)) tets")
        # println("Surface mesh: $(count(meshboundary(fes))) triangles")
    end
    t, v, tmid = meshdata(remesher)
    fens.xyz = v;
    fes = fromarray!(fes, t)
    setlabel!(fes, tmid)
    vtkexportmesh("sample2.vtk", fens, fes);
    # @show length(tmid)
    @test abs(length(tmid) - 7149) / length(tmid) < 0.05
    true
end
end
using .m_flint_mesh_2
m_flint_mesh_2.test()

