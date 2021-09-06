Issues and ideas:


-- Documenter:

```
using Pkg; Pkg.add("DocumenterTools");                                 
using DocumenterTools                                                  
DocumenterTools.genkeys(user="PetrKryslUCSD", repo="git@github.com:PetrKryslUCSD/FinEtoolsVoxelMesher.jl.git")                                                  
using Pkg; Pkg.rm("DocumenterTools"); 
```

- Documentation:

In the `docs` folder do:
using Pkg; Pkg.activate("."); Pkg.instantiate(); 
Then add all necessary packages to run `make.jl`.
