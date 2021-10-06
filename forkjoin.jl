"""
    ForkJoin pattern using channels for collection of results.
	Splits the processing of data into subsequential smaller pieces recursively that can be processed in parallel.
	If indata size is larger than compute_size, computing of data will be split (forked) into two parts
	Thus there can be 1, 2, 4, 8, 16, 32 or more tasks processing the data.
"""

module Forkjoin
export Compute

"""
    Compute method handles the forking of data and calls to the method doing the actual processing of data.
    The method also collects the results from the created channels.
"""
function Compute(indata::Array{String}, result::Channel, compute_size::Int, forks::Array{Int64}) 

    size_indata = length(indata)
	if size_indata <= compute_size 
        forks .+= 1
		t = @task ComputeDirect(indata, result)
        schedule(t);
        #ComputeDirect(indata, result)
		return
    end

    result_fork_a = Channel(1)
    result_fork_b = Channel(2)
    split_at = size_indata ÷ 2

    Compute(indata[1:split_at], result_fork_a, compute_size, forks)
    Compute(indata[split_at+1:size_indata], result_fork_b, compute_size, forks)

    subres = []
    push!(subres, take!(result_fork_a)...)
    push!(subres, take!(result_fork_b)...)
    put!(result, subres)
    return nothing

end

"""
    Implementation of the actual computational logic.
	Could be reduce, sum or whatever you like.
	In this example we are just reversing the text in an array of strings ("Julia" will be "ailuJ").
"""
function ComputeDirect(indata::Array{String}, result::Channel)
    put!(result, indata .|> reverse)
    return nothing
end

end
