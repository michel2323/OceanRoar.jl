#!/bin/sh
#PBS -l filesystems=home:flare
#PBS -l select=1
#PBS -l place=scatter
#PBS -l walltime=1:00:00
#PBS -q debug
#PBS -A Julia
#PBS -N OceanRoar

cd ${PBS_O_WORKDIR}

MPIR_CVAR_ENABLE_GPU=0
NNODES=`wc -l < $PBS_NODEFILE`
NRANKS=1
NDEPTH=4
NTHREADS=4
export JULIA_DEPOT_PATH=/lus/flare/projects/Julia/$USER/julia_depot_path
export JULIA_BIN=/lus/flare/projects/Julia/$USER/juliaup/juliaup/julia-1.10.9+0.x64.linux.gnu/bin/julia
export IGC_OverrideOCLMaxParamSize=4096

NTOTRANKS=$(( NNODES * NRANKS ))
echo "NUM_OF_NODES= ${NNODES} TOTAL_NUM_RANKS= ${NTOTRANKS} RANKS_PER_NODE=${NRANKS} THREADS_PER_RANK= ${NTHREADS}"

# mpiexec -n ${NTOTRANKS} --ppn ${NRANKS_PER_NODE} --depth=${NDEPTH} --cpu-bind depth ${JULIA_BIN} --check-bounds=no --project
mpiexec -n ${NTOTRANKS} -ppn ${NRANKS} --depth=${NDEPTH} --cpu-bind depth -env OMP_NUM_THREADS=${NTHREADS} --env OMP_PLACES=cores ${JULIA_BIN} --project=. near_global_ocean_simulation.jl