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
        t, v, tmid = meshdata(remesher)
        fens.xyz = v
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
    @test length(tmid) == 4725

end
end
using .m_flint_mesh
m_flint_mesh.test()

