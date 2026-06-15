using LinearAlgebra
using QIENO
using Random

rng = MersenneTwister(2026)
coupling = [2.0 -1.0 0.0 -1.0; -1.0 2.0 -1.0 0.0; 0.0 -1.0 2.0 -1.0; -1.0 0.0 -1.0 2.0]
operator = EntropicOperator(coupling; temperature=1.0, dissipation=0.04, noise=0.02)
initial = [0.8, -0.5, 0.3, -0.2]
trajectory = simulate(operator, initial; dt=0.01, steps=250, rng=rng)
scores = [evaluate_stability(operator, view(trajectory, :, k)) for k in axes(trajectory, 2)]

println("Initial stability: ", round(first(scores); digits=4))
println("Minimum stability: ", round(minimum(scores); digits=4))
println("Final state norm: ", round(norm(trajectory[:, end]); digits=4))
