"""Standardize each feature row and return `(transformed, mean, scale)`."""
function standardize(data::AbstractMatrix{T}; epsilon::Real=sqrt(eps(float(T)))) where {T<:Real}
    center = mean(data; dims=2)
    scale = std(data; dims=2, corrected=false)
    safe_scale = max.(scale, epsilon)
    return (data .- center) ./ safe_scale, vec(center), vec(safe_scale)
end

"""Root-mean-square error between equal-sized arrays."""
function rmse(predicted::AbstractArray, observed::AbstractArray)
    size(predicted) == size(observed) || throw(DimensionMismatch("arrays must have equal size"))
    return sqrt(mean(abs2, predicted .- observed))
end
