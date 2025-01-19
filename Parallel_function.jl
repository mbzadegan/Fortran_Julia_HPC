# Save this as parallel_function.jl

function multi_threaded_sum(arr::Vector{Float64})
    total = Threads.Atomic{Float64}(0.0)
    Threads.@threads for i in eachindex(arr)
        total[] += arr[i]
    end
    return total[]
end

