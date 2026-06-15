@testset "Utilities" begin
    data = [1.0 2.0 3.0; 4.0 4.0 4.0]
    transformed, center, scale = standardize(data)
    @test size(transformed) == size(data)
    @test center == [2.0, 4.0]
    @test all(scale .> 0)
    @test rmse(data, data) == 0.0
end
