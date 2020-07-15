"""
    VoxelTetMeshingModule

Module for meshing of voxel data sets with tetrahedra.
"""
module VoxelTetMeshingModule

using FinEtools.FTypesModule: FInt, FFlt, FCplxFlt, FFltVec, FIntVec, FFltMat, FIntMat, FMat, FVec, FDataDict
import ..VoxelBoxModule: VoxelBoxVolume, voxeldims
import FinEtools.MeshTetrahedronModule: T4voximg, tetv
import FinEtools.FESetModule: connasarray
import FinEtools.MeshModificationModule: interior2boundary, vertexneighbors, smoothertaubin
import ..TetRemeshingModule: coarsen
import ..RemesherModule: Remesher, remesh!, volumes, smooth!
import LinearAlgebra: norm
import Statistics: mean

"""
    ImageMesher{CoordT,DataT}

Tetrahedral image mesher.
"""
mutable struct  ImageMesher{CoordT,DataT}
    box::VoxelBoxVolume{CoordT,DataT}
    emptyvoxel::DataT
    notemptyvoxel::Vector{DataT}
    remesher::Remesher
end

function ImageMesher(box::VoxelBoxVolume{CoordT,DataT}, emptyvoxel::DataT, notemptyvoxel::Vector{DataT}) where {CoordT,DataT}
    fens, fes = T4voximg(box.data, vec([voxeldims(box)...]), notemptyvoxel)
    v = deepcopy(fens.xyz)
    t = connasarray(fes)
    tmid = deepcopy(fes.label)
    currentelementsize = mean(vec([voxeldims(box)...]))
    return ImageMesher(box, emptyvoxel, notemptyvoxel, Remesher(v, t, tmid, currentelementsize))
end

function smooth!(self::ImageMesher, npass::Int = 5)
    smooth!(self.remesher, npass)
    return self
end

"""
    mesh!(self::ImageMesher, stretch::FFlt = 1.2)

Perform a meshing step.

If  no mesh exists,  the initial mesh is created; otherwise a coarsening
sequence of coarsen surface -> smooth -> coarsen volume -> smooth is performed.

After meshing the vertices, tetrahedra, and material identifiers,  can be retrieved
as `self.v`, `self.t`, and `self.tmid`.
"""
function remesh!(self::ImageMesher, stretch::FFlt = 1.2)
    remesh!(self.remesher, stretch)
    return self
end

"""
    volumes(self::ImageMesher)

Compute tetrahedral volumes in the current mesh.
"""
function volumes(self::ImageMesher)
    return volumes(self.remesher)
end

end
