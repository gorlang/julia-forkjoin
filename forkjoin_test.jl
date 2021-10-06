#import Pkg; Pkg.add("BenchmarkTools")
using BenchmarkTools
include("forkjoin.jl")
using Main.Forkjoin

"""
Wrapper method for running the Compute() method.
"""
function RunCompute(indata, compute_size, output=[])
    chan = Channel(1)
    forks = [0]
    Compute(indata, chan, compute_size, forks)
    push!(output, take!(chan)...)
    return nothing
end


"""
Generate test data.
"""
function data(n=8)
    values = ["Julia", "Monkey", "Zebra", "Tiger", "Gnu", "Cat", "Eagle", "Antiloop", "Boaconstructor()", "Penguine"]
    return rand(values, n)
end


"""
Test
"""
function test()
    compute_size = 10
    indata = data(compute_size * 3)
    expected = indata .|> reverse
    output = []
    RunCompute(indata, compute_size, output)
    if String.(output) != expected && return AssertionError end
end

test()

"""
Benchmarking
"""
function bench(indata, threads=1)
    compute_size = length(indata) ÷ threads
    RunCompute(indata, compute_size)
end

indata = data(10000)
#@benchmark bench(copy(indata), 1)
@benchmark bench(copy(indata), 8)

