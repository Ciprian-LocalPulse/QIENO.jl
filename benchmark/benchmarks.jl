using QIENO
using Random
using LinearAlgebra

rng = MersenneTwister(1)
dimension = 128
coupling = Matrix{Float64}(I, dimension, dimension)
operator = EntropicOperator(coupling; noise=0.0)
state = randn(rng, dimension)

# Run with BenchmarkTools in a benchmark environment:
# using BenchmarkTools
# @benchmark entropy_production($operator, $state)
println("Warm-up entropy production: ", entropy_production(operator, state))
