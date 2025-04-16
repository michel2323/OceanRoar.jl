using CUDA
using oneAPI
using Adapt
import KernelAbstractions as KA

# Test if the architecture is oneAPI
if CUDA.functional() && oneAPI.functional()
    error("CUDA and oneAPI are both functional. Please ensure that only one of them is functional.")
end

arch = CPU()
backend = KA.CPU()

if CUDA.functional()
    backend = CUDA.CUDABackend()
elseif oneAPI.functional()
    backend = oneAPI.oneAPIBackend()
end

arch = GPU(backend)
println("Backend: ", backend)
