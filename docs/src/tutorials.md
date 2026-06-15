# Tutorials

## Simulating Coupled Dynamics

```@example simulation
using QIENO, Random

L = [1.0 -1.0; -1.0 1.0]
op = EntropicOperator(L; dissipation=0.05, noise=0.01)
path = simulate(op, [1.0, -1.0]; steps=20, rng=MersenneTwister(1))
evaluate_stability(op, path[:, end])
```

## Building a Hypergraph Operator

Columns of the incidence matrix represent hyperedges.

```@example hypergraph
using QIENO

H = [1.0 1.0; 1.0 0.0; 0.0 1.0]
L = hypergraph_laplacian(H)
op = EntropicOperator(L)
```

## Training an Interference Network

Training data is column-major: every column is one sample.

```@example training
using QIENO, Random

rng = MersenneTwister(2)
model = QIENONetwork(3; depth=2, coupling=zeros(3, 3), rng=rng)
x = randn(rng, 3, 32) .* 0.2
y = tanh.(x)
losses = train!(model, x, y; epochs=10)
losses[end]
```

## Optional CUDA Extension

When CUDA.jl is installed and loaded, transfer a model with:

```julia
using QIENO, CUDA
gpu_model = to_device(model, Val(:cuda))
```
