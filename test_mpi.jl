using MPI
using CUDA

MPI.Init()
rank = MPI.Comm_rank(MPI.COMM_WORLD)
size = MPI.Comm_size(MPI.COMM_WORLD)
comm = MPI.COMM_WORLD


include("mpi.jl")
if size != 4
    error("This test requires exactly 4 MPI ranks!")
end

function main()
    # Define ring communication: each rank sends data to its neighbor (rank+1 modulo 4)
    dest = mod(rank + 1, 4)    # destination rank: rank+1 modulo 4
    source = mod(rank - 1, 4)  # source rank: rank-1 modulo 4

    # Each rank sends its own rank value as data
    send_data = CuArray([rank])
    recv_data = CuArray(zeros(Int, 1))

    println("Rank ", rank, " sending ", send_data, " to rank ", dest)

    # Start non-blocking send and receive
    send_req = MPI.Isend(send_data, dest, 0, comm)
    recv_req = MPI.Irecv!(recv_data, source, 0, comm)
    reqs = [send_req, recv_req]

    # Wait for both operations to complete
    MPI.Waitall(reqs)

    println("Rank ", rank, " received ", recv_data, " from rank ", source)

    MPI.Barrier(comm)
    MPI.Finalize()
end

main()
MPI.Finalize()

# if !interactive()
#     # Run the main function in a non-interactive context
#     main()
# else
#     # In an interactive context, we can call the main function directly
#     println("Running in interactive mode. Call main() to execute.")
# end