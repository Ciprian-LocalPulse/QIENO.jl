# Contributing to QIENO.jl

Thank you for helping improve QIENO.jl.

## Development Setup

1. Install Julia 1.10 or later.
2. Clone the repository and start Julia with `julia --project=.`.
3. Run `using Pkg; Pkg.instantiate()`.
4. Run the test suite with `Pkg.test()`.

## Pull Requests

- Keep changes focused and explain the scientific or engineering motivation.
- Add tests for new behavior and regressions.
- Document public APIs with Julia docstrings.
- Avoid unsupported accuracy or performance claims.
- Run `julia --project=. -e "using Pkg; Pkg.test()"` before submitting.

Benchmark contributions must include dataset provenance, preprocessing,
hardware, Julia and package versions, random seeds, baseline configuration,
metrics, and complete reproduction commands.

By contributing, you agree that your contribution is licensed under the MIT
License used by this repository.
