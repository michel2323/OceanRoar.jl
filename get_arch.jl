using CUDA
using oneAPI
using Adapt
using Oceananigans.Architectures
import KernelAbstractions as KA
using MPI

# Test if the architecture is oneAPI
if CUDA.functional() && oneAPI.functional()
    error("CUDA and oneAPI are both functional. Please ensure that only one of them is functional.")
end

arch = Architectures.CPU()
backend = KA.CPU()

if CUDA.functional()
    backend = CUDA.CUDABackend()
elseif oneAPI.functional()
    backend = oneAPI.oneAPIBackend()
end
np = MPI.Comm_size(MPI.COMM_WORLD)
# arch = GPU(backend)
# MPIPreferences.use_jll_binary("OpenMPI_jll")
edge = sqrt(np)
iedge = floor(Int, edge)
@assert floor(iedge)^2 == np "Number of processes must be a perfect square"
arch = Distributed(GPU(backend), partition=Partition(iedge, iedge), synchronized_communication = true)
println("Backend: ", backend)
