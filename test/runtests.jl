using Test
using Random
Random.seed!(6134)


@time @testset "Voxel Box" begin include("test_voxel_box.jl") end
@time @testset "Remeshing" begin include("test_remesher.jl") end

true
