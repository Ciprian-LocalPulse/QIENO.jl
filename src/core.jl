"""
    EntropicOperator(coupling; temperature=1, dissipation=0.05, noise=0.01)

Thermodynamically constrained operator for a graph-coupled stochastic system.
`coupling` is normally a positive-semidefinite graph or hypergraph Laplacian.
"""
struct EntropicOperator{T<:AbstractFloat,M<:AbstractMatrix{T}}
    temperature::T
    dissipation::T
    coupling::M
    noise::T

    function EntropicOperator(
        temperature::T,
        dissipation::T,
        coupling::M,
        noise::T,
    ) where {T<:AbstractFloat,M<:AbstractMatrix{T}}
        temperature > zero(T) || throw(ArgumentError("temperature must be positive"))
        dissipation >= zero(T) || throw(ArgumentError("dissipation must be non-negative"))
        noise >= zero(T) || throw(ArgumentError("noise must be non-negative"))
        size(coupling, 1) == size(coupling, 2) ||
            throw(DimensionMismatch("coupling must be square"))
        new{T,M}(temperature, dissipation, coupling, noise)
    end
end

function EntropicOperator(
    coupling::AbstractMatrix{<:Real};
    temperature::Real=1.0,
    dissipation::Real=0.05,
    noise::Real=0.01,
)
    T = float(promote_type(eltype(coupling), typeof(temperature), typeof(dissipation), typeof(noise)))
    return EntropicOperator(T(temperature), T(dissipation), Matrix{T}(coupling), T(noise))
end

function _check_state(op::EntropicOperator, x::AbstractVector)
    length(x) == size(op.coupling, 1) ||
        throw(DimensionMismatch("state length must match the coupling matrix"))
    return nothing
end

"""Return the instantaneous non-negative entropy-production surrogate."""
function entropy_production(op::EntropicOperator, x::AbstractVector)
    _check_state(op, x)
    dissipative = op.dissipation * dot(x, x)
    coupled = max(dot(x, op.coupling * x), zero(eltype(x)))
    return (dissipative + coupled) / op.temperature
end

"""Compute deterministic drift under dissipation, coupling, and external forcing."""
function entropic_drift(
    op::EntropicOperator,
    x::AbstractVector,
    forcing::AbstractVector=zero(x),
)
    _check_state(op, x)
    length(forcing) == length(x) || throw(DimensionMismatch("forcing must match state"))
    return forcing .- op.dissipation .* x .- op.coupling * x
end

"""Advance a state in place with one Euler-Maruyama step."""
function step!(
    x::AbstractVector{T},
    op::EntropicOperator,
    dt::Real;
    forcing::AbstractVector=zero(x),
    rng::AbstractRNG=Random.default_rng(),
) where {T<:AbstractFloat}
    dt > zero(dt) || throw(ArgumentError("dt must be positive"))
    drift = entropic_drift(op, x, forcing)
    stochastic_scale = op.noise * sqrt(T(dt))
    x .+= T(dt) .* drift .+ stochastic_scale .* randn(rng, T, length(x))
    return x
end

"""Simulate a stochastic trajectory, returning states as columns."""
function simulate(
    op::EntropicOperator,
    initial::AbstractVector{T};
    dt::Real=0.01,
    steps::Integer=100,
    forcing::Union{Nothing,Function}=nothing,
    rng::AbstractRNG=Random.default_rng(),
) where {T<:AbstractFloat}
    steps >= 0 || throw(ArgumentError("steps must be non-negative"))
    state = copy(initial)
    trajectory = Matrix{T}(undef, length(state), steps + 1)
    trajectory[:, 1] = state
    empty_forcing = zeros(T, length(state))
    for k in 1:steps
        force = isnothing(forcing) ? empty_forcing : forcing((k - 1) * dt, state)
        step!(state, op, dt; forcing=force, rng=rng)
        trajectory[:, k + 1] = state
    end
    return trajectory
end

"""
    evaluate_stability(op, x)

Map entropy production to a bounded score in `(0, 1]`; larger values indicate
lower instantaneous dissipation relative to state energy.
"""
function evaluate_stability(op::EntropicOperator, x::AbstractVector)
    normalized = entropy_production(op, x) / (one(eltype(x)) + dot(x, x))
    return exp(-normalized)
end

"""Construct a normalized hypergraph Laplacian from a vertex-edge incidence matrix."""
function hypergraph_laplacian(
    incidence::AbstractMatrix{T};
    weights::AbstractVector=ones(T, size(incidence, 2)),
) where {T<:Real}
    nvertices, nedges = size(incidence)
    length(weights) == nedges || throw(DimensionMismatch("one weight is required per edge"))
    all(weights .>= zero(eltype(weights))) || throw(ArgumentError("weights must be non-negative"))

    edge_degree = vec(sum(incidence; dims=1))
    vertex_degree = vec(incidence * weights)
    all(edge_degree .> zero(T)) || throw(ArgumentError("hyperedges may not be empty"))

    inv_edge = Diagonal(inv.(float.(edge_degree)))
    inv_sqrt_vertex = Diagonal(map(vertex_degree) do degree
        degree > zero(degree) ? inv(sqrt(float(degree))) : zero(float(degree))
    end)
    weighted_edges = Diagonal(float.(weights))
    normalized_adjacency =
        inv_sqrt_vertex * incidence * weighted_edges * inv_edge * transpose(incidence) * inv_sqrt_vertex
    return Matrix{eltype(normalized_adjacency)}(I, nvertices, nvertices) - normalized_adjacency
end

"""Keep an object on the CPU. Optional extensions add other devices."""
to_device(x, ::Val{:cpu}) = x
