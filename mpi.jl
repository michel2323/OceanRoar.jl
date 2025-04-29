# --- Begin custom MPI functions for CuArray double buffering ---
using CUDA
# Override Isend for CuArray: copy device data to a host Array and send from it.
function MPI.Isend(data::CuArray{T,1}, dest::Integer, tag::Integer, comm::MPI.Comm) where T
    host_data = Array(data)  # copy device to host
    return MPI.Isend(host_data, dest, tag, comm)
end

# Custom request type for non-blocking device receives.
mutable struct CuIrecvRequest{T} <: MPI.AbstractRequest
    req::MPI.Request
    device_array::CuArray{T}
    host_buffer::Vector{T}
end

# Override Irecv! for CuArray: receive into a host buffer.
function MPI.Irecv!(dest::CuArray{T,1}, source::Integer, tag::Integer, comm::MPI.Comm) where T
    host_buffer = similar(Array(dest))
    req = MPI.Irecv!(host_buffer, source, tag, comm)
    return CuIrecvRequest{T}(req, dest, host_buffer)
end

# Override Wait so that when waiting on our custom request the host buffer is copied back.
function MPI.Wait(r::CuIrecvRequest)
    MPI.Wait(r.req)
    copyto!(r.device_array, r.host_buffer)  # Copy data back to device
    return r.device_array
end

# Override Waitall to support a mix of standard and custom MPI requests.
function MPI.Waitall(reqs::Vector)
    for r in reqs
        if r isa CuIrecvRequest
            MPI.Wait(r)
        else
            MPI.Wait(r)
        end
    end
end
