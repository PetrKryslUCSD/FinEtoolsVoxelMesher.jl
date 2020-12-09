module labrador_examples
using FinEtools
using MappedArrays
using NIfTI
using FinEtoolsVoxelMesher
using FinEtools.MeshExportModule
using Test
import LinearAlgebra: norm, cholesky, I, eigen
using UnicodePlots


function labrador_1()
	@warn "This example will run for several minutes"
	File = "lab-sm2-cl-mid-sep"
	file = niread(File * ".nii")
	file.header.xyzt_units = 2 # units are not set for some reason
	bs = voxel_size(file.header) .* [size(file,1), size(file,2), size(file,3)]
	vb = VoxelBoxVolume(file.raw[:, :, :, 1], bs)
	# vtkexport(File * ".vtk", vb)

	# Set up the mesher
	im = ImageMesher(vb, zero(eltype(vb.data)), eltype(vb.data)[100, 200])
	# We wish to refine the mesh around the molars on the left-hand side
	setelementsizeweightfunctions(im.remesher, [ElementSizeWeightFunction(20.0, vec([154.0, 158.0, 98.0]), 20.0)])
	
	# Generate the initial mesh
	println("Data read, generating initial mesh")
	t, v, tmid = meshdata(im)
	println("Mesh size: initial = $(size(t,1)) tetrahedra")
	fens = FENodeSet(v)
	fes = FESetT4(t)
	setlabel!(fes, tmid)
	println("Exporting boundary mesh")
	bfes = meshboundary(fes)
	File = "lab-sm2-cl-mid-sep.vtk"
	vtkexportmesh(File, fens, bfes)
	@async run(`"paraview.exe" $File`)
	println("Done")

	# Now the element size will be increased, which will reduce the number of
	# tetrahedra
	println("Reducing the size of the mesh")
	for i = 1:7
	    remesh!(im)
	    updatecurrentelementsize!(im, 1.2*im.remesher.currentelementsize)
	    t, v, tmid = meshdata(im)
	    println("Mesh size: intermediate = $(size(t,1)) tetrahedra")
	end
	println("Done")

	# The final produced mesh will be now exported for visualization
	println("Exporting the final mesh as a surface")
	t, v, tmid = meshdata(im)
	fens = FENodeSet(v)
	fes = FESetT4(t)
	setlabel!(fes, tmid)
	bfes = meshboundary(fes)
	File = "lab-sm2-cl-mid-sep.vtk"
	vtkexportmesh(File, fens, bfes)
	@async run(`"paraview.exe" $File`)
	println("Done")

	# Now save the mesh
	FinEtools.MeshExportModule.MESH.write_MESH("lab-sm2-cl-mid-sep.mesh", fens, fes)

	# If needed, save the NASTRAN file
	# ne = NASTRANExporter("lab-sm2-cl-mid.nas")
	# BEGIN_BULK(ne)
	# for i = 1:count(fens)
	#     GRID(ne, i, fens.xyz[i, :])
	# end
	# for i = 1:count(fes)
	#     CTETRA(ne, i, 1, fes.conn[i, :])
	# end
	# PSOLID(ne, 1, 1)
	# MAT1(ne, 1, 20.0e9, 0.3, 1800.0)
	# ENDDATA(ne)
	# close(ne)
	return true
end

function allrun()
    println("#####################################################")
    println("# labrador_1 ")
    labrador_1()
    return true
end # function allrun

end # module labrador_examples
