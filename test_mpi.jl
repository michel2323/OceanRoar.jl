using MPI
using CUDA

MPI.Init()
rank = MPI.Comm_rank(MPI.COMM_WORLD)
size = MPI.Comm_size(MPI.COMM_WORLD)
comm = MPI.COMM_WORLD


include("double_buffer.jl")
if size != 4
    error("This test requires exactly 4 MPI ranks!")
end

function main(::Val{T}) where T
    # Define ring communication: each rank sends data to its neighbor (rank+1 modulo 4)
    dest = mod(rank + 1, 4)    # destination rank: rank+1 modulo 4
    source = mod(rank - 1, 4)  # source rank: rank-1 modulo 4

    # Each rank sends its own rank value as data
    send_data = T([rank])
    recv_data = T((zeros(Int, 1)))

    println("Rank ", rank, " sending ", send_data, " to rank ", dest)

    # Start non-blocking send and receive
    send_req = MPI.Isend(DoubleBuffer(send_data), dest, 0, comm)
    recv_req = MPI.Irecv!(DoubleBuffer(recv_data), source, 0, comm)
    @show typeof(send_req)
    @show typeof(recv_req)
    reqs = [send_req, recv_req]

    # Wait for both operations to complete
    MPI.Waitall(reqs)

    println("Rank ", rank, " received ", recv_data, " from rank ", source)

    MPI.Barrier(comm)
    MPI.Finalize()
end

main(Val(Array))
MPI.Finalize()

# if !interactive()
#     # Run the main function in a non-interactive context
#     main()
# else
#     # In an interactive context, we can call the main function directly
#     println("Running in interactive mode. Call main() to execute.")
# end