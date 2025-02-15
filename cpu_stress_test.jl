# Run the program with Julia,
# ```julia -t auto cpu_stress_test.jl```
# Use -t auto to automatically use all available CPU Core/Threads.

using LinearAlgebra
using Random
using Distributed
using .Threads

# Enable all available threads
Threads.nthreads()

# Function to multiply two matrices in parallel
function parallel_matrix_multiplication(A, B)
    n = size(A, 1)
    C = zeros(eltype(A), n, n)  # Initialize result matrix
    @threads for i in 1:n
        for j in 1:n
            C[i, j] = dot(A[i, :], B[:, j])
        end
    end
    return C
end

# Generate two random matrices
n = 1000  # Size of the square matrices
A = rand(n, n)
B = rand(n, n)

# Measure CPU processing time
@time begin
    C = parallel_matrix_multiplication(A, B)
end

println("Matrix multiplication complete!")
