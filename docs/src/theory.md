# Theory

## Entropic Dynamics

For a state vector ``x \in \mathbb{R}^n``, QIENO uses the stochastic model

```math
dx_t = \left(f_t - \gamma x_t - Lx_t\right)dt + \sigma dW_t,
```

where ``L`` is a graph or hypergraph coupling operator, ``\gamma`` is local
dissipation, ``f_t`` is external forcing, and ``\sigma`` controls stochastic
excitation. `simulate` integrates this equation with Euler-Maruyama.

The entropy-production surrogate is

```math
\dot S(x) = \frac{\gamma \|x\|_2^2 + \max(x^\top Lx, 0)}{T}.
```

The `max` guard preserves a non-negative diagnostic even when users provide a
coupling matrix that is not numerically positive semidefinite. A physically
motivated model should still use a validated Laplacian or comparable operator.

## Quantum-Inspired Layers

Each real-valued interference layer computes

```math
h' = \tanh\left(Wh + U\sin(\phi \odot h) + b\right).
```

The sinusoidal phase path borrows interference-like structure but does not
simulate quantum hardware or claim quantum advantage.

## Limitations

- The current integrator is fixed-step Euler-Maruyama.
- The stability score is a bounded heuristic, not a calibrated probability.
- Dense matrices limit very large graph workloads.
- Comparative accuracy and speed claims require domain-specific benchmarks.
