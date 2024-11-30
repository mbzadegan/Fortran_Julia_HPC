# HPC_Fortran_Julia
High-Performance Computing by linking Fortran and Julia:




1. Ensure that Julia's threading is enabled by setting the JULIA_NUM_THREADS environment variable before running the program:

configure bash with:

export JULIA_NUM_THREADS=24 or your available threads count (4, 8, ...etc)

2. Compile the Fortran Code:

Use gfortran (or another Fortran compiler) to compile the code, linking against Julia's shared library:

gfortran -o call_julia call_julia.f90 -L/path/to/julia/lib -ljulia


3. Ensure the Julia shared library and parallel_function.jl file are in the correct paths, then execute the program:

./call_julia

