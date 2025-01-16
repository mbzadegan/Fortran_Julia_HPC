# Run the program with Julia,
# ```julia -t auto cpu_stress_test.jl```
# Use -t auto to automatically use all available CPU threads.

using Base.Threads
using Printf
using Dates

# Function to perform heavy computation
function stress_thread(n)
    x = 0.0
    for i in 1:n
        x += sin(i) * cos(i)
    end
    return x
end

# Main function for CPU stress test
function cpu_stress_test(iterations_per_thread)
    num_threads = nthreads()
    println("Starting CPU stress test with $num_threads threads...")
    
    start_time = now()  # Record start time
    
    # Launch tasks for all threads
    results = Vector{Task}(undef, num_threads)
    for t in 1:num_threads
        results[t] = @spawn stress_thread(iterations_per_thread)
    end
    
    # Wait for all threads to finish
    total_result = sum(fetch.(results))
    
    end_time = now()  # Record end time
    elapsed_time = end_time - start_time
    
    @printf("CPU stress test completed.\n")
    @printf("Total result (checksum): %.5f\n", total_result)
    @printf("Elapsed time: %s\n", elapsed_time)
end

# Parameters
iterations_per_thread = 10^8  # Increase for higher stress

# Run the stress test
cpu_stress_test(iterations_per_thread)
