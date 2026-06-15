<p align="center">
  <img src="assets/logo.png" width="220" alt="QIENO.jl logo">
</p>

# QIENO.jl

**Quantum-Inspired Entropic Neural Operators for complex dynamical systems**

[![CI](https://github.com/Ciprian-LocalPulse/QIENO.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/Ciprian-LocalPulse/QIENO.jl/actions/workflows/CI.yml)
[![Documentation](https://github.com/Ciprian-LocalPulse/QIENO.jl/actions/workflows/Documentation.yml/badge.svg)](https://ciprian-localpulse.github.io/QIENO.jl/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Julia](https://img.shields.io/badge/Julia-1.10%2B-9558B2.svg)](https://julialang.org/)

QIENO.jl is an experimental scientific machine-learning framework that combines
graph geometry, stochastic dynamics, quantum-inspired interference layers, and
non-equilibrium entropy-production surrogates. It is designed for research on
early-warning signals in tightly coupled systems such as energy microgrids,
distributed software infrastructure, and market simulations.

> [!IMPORTANT]
> QIENO.jl is research software. It does not claim guaranteed collapse
> prediction, 100x accuracy, or fitness for safety-critical, medical, energy,
> or financial decisions. Such claims require peer-reviewed evidence and
> reproducible domain benchmarks.

## Why QIENO?

Many instability detectors treat a complex system as a flat time series.
QIENO instead represents structural coupling explicitly and evolves a state
under a thermodynamically constrained stochastic operator. A neural
interference stack can then learn nonlinear state transformations while an
entropy-derived score provides an interpretable stability signal.

For state $x$, coupling operator $L$, temperature $T$, and dissipation $\gamma$,
the current entropy-production surrogate is

$$
\dot{S}(x) = \frac{\gamma\lVert x\rVert_2^2 + \max(x^\top Lx, 0)}{T}.
$$

The bounded stability score is

$$
s(x) = \exp\left(-\frac{\dot{S}(x)}{1 + \lVert x\rVert_2^2}\right).
$$

These equations are modeling primitives, not universal physical laws. Users
should validate the operator and calibration against their own system.

## Features

- Graph- and hypergraph-aware entropic operators
- Euler-Maruyama simulation of stochastic coupled dynamics
- Quantum-inspired real-valued interference layers
- Dependency-light, deterministic full-batch training
- Type-stable core APIs covered by `@inferred` tests
- Optional CUDA extension loaded only when CUDA.jl is present
- Cross-platform CI and Documenter.jl documentation

## Quick Start

```julia
using Pkg
Pkg.add(url="https://github.com/Ciprian-LocalPulse/QIENO.jl")
```

```julia
using QIENO, Random

L = [ 2.0 -1.0  0.0 -1.0;
     -1.0  2.0 -1.0  0.0;
      0.0 -1.0  2.0 -1.0;
     -1.0  0.0 -1.0  2.0]

op = EntropicOperator(L; dissipation=0.04, noise=0.02)
x0 = [0.8, -0.5, 0.3, -0.2]
path = simulate(op, x0; dt=0.01, steps=250, rng=MersenneTwister(7))
score = evaluate_stability(op, path[:, end])
println("Final stability score: ", round(score; digits=4))
```

Train a quantum-inspired operator:

```julia
using QIENO, Random

rng = MersenneTwister(42)
model = QIENONetwork(4; depth=2, coupling=zeros(4, 4), rng=rng)
inputs = randn(rng, 4, 128) .* 0.2
targets = tanh.(inputs)
losses = train!(model, inputs, targets; epochs=100, learning_rate=0.01)
prediction = predict(model, inputs[:, 1])
```

## Research Roadmap

- Reproducible benchmark suites for microgrids and distributed systems
- Differentiable SDE solver integration with SciML
- Sparse and temporal hypergraph operators
- Calibrated uncertainty and collapse-event metrics
- GPU benchmark publication and kernel optimization
- Peer-reviewed mathematical and empirical validation

## Benchmarks

The repository includes a transparent benchmark entry point in
[`benchmark/benchmarks.jl`](benchmark/benchmarks.jl). Comparative performance
figures will be published only with hardware, software versions, datasets,
baselines, confidence intervals, and complete reproduction commands. No
unverified Python or C++ superiority claim is presented as fact.

## Documentation

The complete guide covers the mathematical model, API, tutorials, extension
mechanism, and research limitations. After the first documentation deployment,
it will be available at <https://ciprian-localpulse.github.io/QIENO.jl/>.

## Contributing and Citation

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md), open an
issue for substantial changes, and include tests for new behavior. If QIENO.jl
contributes to your research, cite [`CITATION.cff`](CITATION.cff).

## Support & Donations

QIENO.jl is free and open-source under the MIT License. If this project helps
your hospital, clinic, research institution, or engineering team, please
consider supporting continued independent research and development.

### PayPal

<https://paypal.me/agentflowenterprise>

### Bank Transfer (EUR / SEPA)

| Field | Value |
|---|---|
| Name | Ciprian Stefan Plesca |
| IBAN | `BE83 9679 1975 8915` |
| BIC/SWIFT | `TRWIBEB1XXX` |
| Bank | Wise, Rue du Trone 100, Brussels, Belgium |

### Bank Transfer (GBP)

| Field | Value |
|---|---|
| Name | Ciprian Stefan Plesca |
| Account Number | `92055372` |
| Sort Code | `23-14-70` |
| IBAN | `GB68 TRWI 2314 7092 0553 72` |
| BIC/SWIFT | `TRWIGB2LXXX` |

### Bank Transfer (USD)

| Field | Value |
|---|---|
| Name | Ciprian Stefan Plesca |
| Account Type | Checking |
| Routing Number | `026073150` |
| Account Number | `8314225367` |
| BIC/SWIFT | `CMFGUS33` |
| Bank | Community Federal Savings Bank, 89-16 Jamaica Ave, Woodhaven, NY 11421, USA |

### Cryptocurrency

| Currency | Address |
|---|---|
| Bitcoin (BTC) | `bc1qf3yy0w8z37rwavxpu38wem3yffpanw7wzj32qj` |
| Ethereum (ETH) | `0x27d9a6a5b8507e6031bb044319410da96222d402` |

## License

Copyright (c) 2026 Ciprian Stefan Plesca. Released under the [MIT License](LICENSE).
