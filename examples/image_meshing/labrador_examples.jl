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

	im = ImageMesher(vb, zero(eltype(vb.data)), eltype(vb.data)[100, 200])
	im.elementsizeweightfunctions = [ElementSizeWeightFunction(20.0, vec([154.0, 158.0, 98.0]), 20.0)]
	println("Data read, generating initial mesh")
	mesh!(im)
	println("Mesh size: initial = $(size(im.t,1)) tetrahedra")
	fens = FENodeSet(im.v)
	fes = FESetT4(im.t)
	setlabel!(fes, im.tmid)
	println("Exporting boundary mesh")
	bfes = meshboundary(fes)
	File = "lab-sm2-cl-mid-sep.vtk"
	vtkexportmesh(File, fens, bfes)
	@async run(`"paraview.exe" $File`)
	println("Done")

	println("Reducing the size of the mesh")
	for i = 1:7
	    mesh!(im, 1.2)
	    println("Mesh size: intermediate = $(size(im.t,1)) tetrahedra")
	end
	println("Done")

	println("Exporting the final mesh as a surface")
	fens = FENodeSet(im.v)
	fes = FESetT4(im.t)
	setlabel!(fes, im.tmid)
	bfes = meshboundary(fes)
	File = "lab-sm2-cl-mid-sep.vtk"
	vtkexportmesh(File, fens, bfes)
	@async run(`"paraview.exe" $File`)
	println("Done")

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
