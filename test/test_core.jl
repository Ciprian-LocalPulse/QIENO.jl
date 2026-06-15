using LinearAlgebra
using Random

@testset "Entropic core" begin
    coupling = [1.0 -1.0; -1.0 1.0]
    op = EntropicOperator(coupling; temperature=2.0, dissipation=0.1, noise=0.0)
    state = [1.0, -1.0]

    @test entropy_production(op, state) >= 0.0
    @test @inferred(evaluate_stability(op, state)) isa Float64
    @test 0.0 < evaluate_stability(op, state) <= 1.0
    @test entropic_drift(op, zeros(2)) == zeros(2)

    trajectory = simulate(op, state; dt=0.01, steps=10, rng=MersenneTwister(7))
    @test size(trajectory) == (2, 11)
    @test trajectory[:, 1] == state

    incidence = [1.0 1.0; 1.0 0.0; 0.0 1.0]
    laplacian = hypergraph_laplacian(incidence)
    @test size(laplacian) == (3, 3)
    @test isapprox(laplacian, transpose(laplacian); atol=1e-12)
    @test eigmin(Symmetric(laplacian)) >= -1e-12
end
