module QIENO_CUDAExt

using CUDA
using QIENO

function QIENO.to_device(op::QIENO.EntropicOperator, ::Val{:cuda})
    return QIENO.EntropicOperator(
        op.temperature,
        op.dissipation,
        CuArray(op.coupling),
        op.noise,
    )
end

function QIENO.to_device(layer::QIENO.QuantumLayer, ::Val{:cuda})
    return QIENO.QuantumLayer(
        CuArray(layer.mixing),
        CuArray(layer.interference),
        CuArray(layer.phase),
        CuArray(layer.bias),
    )
end

function QIENO.to_device(network::QIENO.QIENONetwork, ::Val{:cuda})
    layers = [QIENO.to_device(layer, Val(:cuda)) for layer in network.layers]
    return QIENO.QIENONetwork(layers, QIENO.to_device(network.operator, Val(:cuda)))
end

end
