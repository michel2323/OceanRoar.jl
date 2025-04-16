# From Oceananigans.jl/test/test_oneapi.jl

using oneAPI
using CUDA
using Adapt
using Test
using Oceananigans
using Oceananigans.Architectures
using KernelAbstractions
import Oceananigans.Units: minute, minutes, hours
include("get_arch.jl")
@testset "oneAPI extension" begin
    grid = RectilinearGrid(arch, size=(4, 8, 16), x=[0, 1, 2, 3, 4], y=(0, 1), z=(0, 16))
    @test get_backend(parent(grid.xᶠᵃᵃ)) == backend
    @test get_backend(parent(grid.xᶜᵃᵃ)) == backend
    @test eltype(grid) == Float64
    @test architecture(grid) isa GPU

    model = HydrostaticFreeSurfaceModel(; grid,
                                        coriolis = FPlane(latitude=45),
                                        buoyancy = BuoyancyTracer(),
                                        tracers = :b,
                                        momentum_advection = WENO(order=5),
                                        tracer_advection = WENO(order=5),
                                        free_surface = SplitExplicitFreeSurface(grid; substeps=60))

    @test get_backend(parent(model.velocities.u)) == backend
    @test get_backend(parent(model.velocities.v)) == backend
    @test get_backend(parent(model.velocities.w)) == backend
    @test get_backend(parent(model.tracers.b)) == backend

    simulation = Simulation(model, Δt=1minute, stop_iteration=3)
    run!(simulation)

    @test iteration(simulation) == 3
    @test time(simulation) == 3minutes
end