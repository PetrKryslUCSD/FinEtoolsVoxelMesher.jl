# Guide

## Modules

The `FinEtools` package consists of many modules which fall into several  categories. The top-level module, `FinEtools`, includes all other modules and exports functions to constitute the public interface.

The `FinEtoolsVoxelMesher` package has the following structure:
- Top-level:
     `FinEtoolsVoxelMesher` is the  top-level module.  

- `VoxelBoxModule`: This module implements functions to generate and modify  CT scan and other medical images.
- `VoxelTetMeshingModule`: Implement functions to mesh and re-mesh voxel images with tetrahedral elements. The remeshing itself is implemented in `TetRemeshingModule`.
