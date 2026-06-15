using Random

@testset "Quantum-inspired network" begin
    rng = MersenneTwister(42)
    network = QIENONetwork(3; depth=2, coupling=zeros(3, 3), rng=rng)
    input = [0.2, -0.1, 0.4]

    prediction = @inferred predict(network, input)
    @test prediction isa Vector{Float64}
    @test length(prediction) == 3
    @test all(isfinite, prediction)

    inputs = randn(rng, 3, 16) .* 0.2
    targets = tanh.(inputs)
    losses = train!(network, inputs, targets; epochs=8, learning_rate=0.01)
    @test length(losses) == 8
    @test all(isfinite, losses)
    @test losses[end] <= losses[1] * 1.1
end
