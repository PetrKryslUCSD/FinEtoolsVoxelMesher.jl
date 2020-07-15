using Test

@time @testset "Remeshing" begin include("test_remesher.jl") end
@time @testset "Meshing" begin include("test_voxel_box.jl") end

true
