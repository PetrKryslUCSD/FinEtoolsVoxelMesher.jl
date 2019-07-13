# Types

## FEM machines

### Linear deformation

```@autodocs
Modules = [FinEtools, FinEtoolsDeforLinear.DeforModelRedModule, FinEtoolsDeforLinear.FEMMDeforLinearBaseModule, FinEtoolsDeforLinear.FEMMDeforLinearModule, FinEtoolsDeforLinear.FEMMDeforWinklerModule, FinEtoolsDeforLinear.FEMMDeforLinearMSModule, FinEtoolsDeforLinear.FEMMDeforSurfaceDampingModule, FinEtoolsDeforLinear.FEMMDeforLinearNICEModule, FinEtoolsDeforLinear.FEMMDeforLinearESNICEModule]
Private = true
Order = [:type]
```

## Material models

### Material for deformation, base functionality

```@autodocs
Modules = [FinEtools, FinEtoolsDeforLinear.MatDeforModule]
Private = true
Order = [:type]
```

### Material models for elasticity

```@autodocs
Modules = [FinEtools, FinEtoolsDeforLinear.MatDeforLinearElasticModule, FinEtoolsDeforLinear.MatDeforElastIsoModule, FinEtoolsDeforLinear.MatDeforElastOrthoModule,]
Private = true
Order = [:type]
```
