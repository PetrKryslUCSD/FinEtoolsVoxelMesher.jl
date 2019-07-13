# Functions

## FEM machines

### Linear deformation

#### Model reduction types

```@autodocs
Modules = [FinEtools, FinEtoolsDeforLinear.DeforModelRedModule]
Private = true
Order = [:function]
```

#### Base functionality

```@autodocs
Modules = [FinEtools, FinEtoolsDeforLinear.FEMMDeforLinearBaseModule, FinEtoolsDeforLinear.FEMMDeforLinearModule, FinEtoolsDeforLinear.FEMMDeforWinklerModule, FinEtoolsDeforLinear.FEMMDeforLinearMSModule, FinEtoolsDeforLinear.FEMMDeforSurfaceDampingModule, FinEtoolsDeforLinear.FEMMDeforLinearNICEModule, FinEtoolsDeforLinear.FEMMDeforLinearESNICEModule]
Private = true
Order = [:function]
```

#### Simple FE models

```@autodocs
Modules = [FinEtools, FinEtoolsDeforLinear.FEMMDeforLinearModule, FinEtoolsDeforLinear.FEMMDeforWinklerModule,  FinEtoolsDeforLinear.FEMMDeforSurfaceDampingModule, ]
Private = true
Order = [:function]
```

#### Advanced FE models

```@autodocs
Modules = [FinEtools, FinEtoolsDeforLinear.FEMMDeforLinearMSModule, FinEtoolsDeforLinear.FEMMDeforLinearNICEModule, FinEtoolsDeforLinear.FEMMDeforLinearESNICEModule]
Private = true
Order = [:function]
```

## Algorithms

### Linear deformation

```@autodocs
Modules = [FinEtools, FinEtoolsDeforLinear.AlgoDeforLinearModule]
Private = true
Order = [:function]
```

## Material models

### Material for deformation, base functionality

```@autodocs
Modules = [FinEtools, FinEtoolsDeforLinear.MatDeforModule]
Private = true
Order = [:function]
```

### Material models for elasticity

```@autodocs
Modules = [FinEtools, FinEtoolsDeforLinear.MatDeforLinearElasticModule, FinEtoolsDeforLinear.MatDeforElastIsoModule, FinEtoolsDeforLinear.MatDeforElastOrthoModule,]
Private = true
Order = [:function]
```
