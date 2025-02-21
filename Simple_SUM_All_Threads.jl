# Run in shell by:
# julia -t auto Simple_SUM_All_Threads.jl
# This command automatically uses all available threads



using Base.Threads

function sum_n_threads(n)
    s = zeros(Int, nthreads())  # One sum per thread
    @threads for i in 1:n
        s[threadid()] += i
    end
    return sum(s)
end

@time sum_n_threads(10^12)
