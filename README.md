[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Build status](https://github.com/PetrKryslUCSD/FinEtoolsVoxelMesher.jl/workflows/CI/badge.svg)](https://github.com/PetrKryslUCSD/FinEtoolsVoxelMesher.jl/actions)
[![Code Coverage](https://codecov.io/gh/PetrKryslUCSD/FinEtoolsVoxelMesher.jl/branch/master/graph/badge.svg)](https://app.codecov.io/gh/PetrKryslUCSD/FinEtoolsVoxelMesher.jl)
[![Latest documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://petrkryslucsd.github.io/FinEtoolsVoxelMesher.jl/latest)
[![Codebase Graph](https://img.shields.io/badge/Codebase-graph-green.svg)](https://octo-repo-visualization.vercel.app/?repo=PetrKryslUCSD/FinEtoolsVoxelMesher.jl)

# FinEtoolsVoxelMesher: Meshing of voxel volumes


[`FinEtools`](https://github.com/PetrKryslUCSD/FinEtools.jl.git) is a package
for basic operations on finite element meshes. `FinEtoolsVoxelMesher` uses `FinEtools` to mesh three-dimensional geometries defined as voxel volumes.

## News

- 02/27/2024: Updated for Julia 1.10.
- 07/06/2023: Updated for Julia 1.9.

[Past news](#past-news)


<img src="http://hogwarts.ucsd.edu/~pkrysl/site.images/Labrador.png">
<img src="http://hogwarts.ucsd.edu/~pkrysl/site.images/Labrador-teeth-30.png">

## Examples


There are a number of examples. The examples may
be executed as described in the  [conceptual guide to
`FinEtools`](https://petrkryslucsd.github.io/FinEtools.jl/latest).


## <a name="past-news"></a>Past news

- 07/05/2022: Updated for Julia 1.7.
- 02/08/2021: Updated dependencies for Julia 1.6 and FinEtools 5.0.
- 12/08/2020: The coarsening now handles multi-material domains.
- 01/23/2020: Dependencies have been updated to work with Julia 1.3.1.
- 12/19/2019: Updated NIfTI.
- 07/13/2019: Applications are now separated  out from the `FinEtools` package.