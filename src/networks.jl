"""A real-valued, quantum-inspired interference layer."""
mutable struct QuantumLayer{T<:AbstractFloat,M<:AbstractMatrix{T},V<:AbstractVector{T}}
    mixing::M
    interference::M
    phase::V
    bias::V
end

function QuantumLayer(
    dimension::Integer;
    scale::Real=0.15,
    rng::AbstractRNG=Random.default_rng(),
    T::Type{<:AbstractFloat}=Float64,
)
    dimension > 0 || throw(ArgumentError("dimension must be positive"))
    mixing = Matrix{T}(I, dimension, dimension) .+ T(scale) .* randn(rng, T, dimension, dimension)
    interference = T(scale) .* randn(rng, T, dimension, dimension)
    phase = T(2pi) .* rand(rng, T, dimension)
    bias = zeros(T, dimension)
    return QuantumLayer(mixing, interference, phase, bias)
end

function _forward(layer::QuantumLayer, x::AbstractVector)
    wave = sin.(layer.phase .* x)
    preactivation = layer.mixing * x + layer.interference * wave + layer.bias
    return tanh.(preactivation), wave
end

(layer::QuantumLayer)(x::AbstractVector) = first(_forward(layer, x))

"""A stack of interference layers coupled to an entropic stability operator."""
mutable struct QIENONetwork{T<:AbstractFloat,L<:QuantumLayer{T},O<:EntropicOperator{T}}
    layers::Vector{L}
    operator::O
end

function QIENONetwork(
    dimension::Integer;
    depth::Integer=2,
    coupling::AbstractMatrix=Matrix{Float64}(I, dimension, dimension),
    rng::AbstractRNG=Random.default_rng(),
    T::Type{<:AbstractFloat}=Float64,
)
    depth > 0 || throw(ArgumentError("depth must be positive"))
    layers = [QuantumLayer(dimension; rng=rng, T=T) for _ in 1:depth]
    operator = EntropicOperator(T.(coupling))
    return QIENONetwork(layers, operator)
end

"""Run a state through every quantum-inspired layer."""
function predict(network::QIENONetwork, x::AbstractVector)
    output = x
    for layer in network.layers
        output = layer(output)
    end
    return output
end

(network::QIENONetwork)(x::AbstractVector) = predict(network, x)

evaluate_stability(network::QIENONetwork, x::AbstractVector) =
    evaluate_stability(network.operator, predict(network, x))

"""
    train!(network, inputs, targets; epochs=100, learning_rate=1e-2)

Train on column-major samples with deterministic full-batch gradient descent.
Returns the mean-squared-error history.
"""
function train!(
    network::QIENONetwork{T},
    inputs::AbstractMatrix,
    targets::AbstractMatrix;
    epochs::Integer=100,
    learning_rate::Real=1e-2,
) where {T}
    size(inputs) == size(targets) || throw(DimensionMismatch("inputs and targets must match"))
    size(inputs, 1) == size(network.layers[1].mixing, 1) ||
        throw(DimensionMismatch("sample dimension must match the network"))
    epochs >= 0 || throw(ArgumentError("epochs must be non-negative"))
    learning_rate > 0 || throw(ArgumentError("learning_rate must be positive"))
    nsamples = size(inputs, 2)
    nsamples > 0 || throw(ArgumentError("at least one sample is required"))
    losses = Vector{T}(undef, epochs)
    nlayers = length(network.layers)

    for epoch in 1:epochs
        grad_mixing = [zeros(T, size(layer.mixing)) for layer in network.layers]
        grad_interference = [zeros(T, size(layer.interference)) for layer in network.layers]
        grad_phase = [zeros(T, size(layer.phase)) for layer in network.layers]
        grad_bias = [zeros(T, size(layer.bias)) for layer in network.layers]
        total_loss = zero(T)

        for sample in 1:nsamples
            activations = Vector{Vector{T}}(undef, nlayers + 1)
            waves = Vector{Vector{T}}(undef, nlayers)
            activations[1] = T.(inputs[:, sample])
            for index in 1:nlayers
                activations[index + 1], waves[index] = _forward(network.layers[index], activations[index])
            end

            error = activations[end] .- targets[:, sample]
            total_loss += sum(abs2, error) / length(error)
            delta = (T(2) / length(error)) .* error .* (one(T) .- activations[end].^2)

            for index in nlayers:-1:1
                layer = network.layers[index]
                previous = activations[index]
                grad_mixing[index] .+= delta * transpose(previous)
                grad_interference[index] .+= delta * transpose(waves[index])
                grad_bias[index] .+= delta
                interference_signal = transpose(layer.interference) * delta
                grad_phase[index] .+= interference_signal .* cos.(layer.phase .* previous) .* previous
                if index > 1
                    propagated = transpose(layer.mixing) * delta
                    propagated .+= layer.phase .* cos.(layer.phase .* previous) .* interference_signal
                    delta = propagated .* (one(T) .- activations[index].^2)
                end
            end
        end

        scale = T(learning_rate / nsamples)
        for index in 1:nlayers
            layer = network.layers[index]
            layer.mixing .-= scale .* grad_mixing[index]
            layer.interference .-= scale .* grad_interference[index]
            layer.phase .-= scale .* grad_phase[index]
            layer.bias .-= scale .* grad_bias[index]
        end

        losses[epoch] = total_loss / nsamples
    end
    return losses
end
