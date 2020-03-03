__precompile__()

module JUnitTestSets

export JUnitTestSet, write_report, check_test_results, @jtestset, @jtest

using Test, Dates
include("JTestResult.jl")

struct JUnitTestSet
    id::String
    name::String
    tests::Int
    failures::Int
    time::Dates.Nanosecond
    results::Vector{JTestResult}
end

function evaluate_tests(arr)::JUnitTestSet
    evals::Vector{JTestResult} = []
    for a in arr
        if typeof(a) == JUnitTestSets.JTestResult
            push!(evals, eval(a))
        end
    end
    tests = length(evals)
    failures = length(filter(x -> !x.result, evals))
    etime = sum(map(x -> x.time, evals))
    return JUnitTestSet("tests", "Julia Tests", tests, failures, etime, evals)
end

function check_test_results(ts::JUnitTestSet)
    # Return 1 if any tests have failed, otherwise return 0. Handy for CI
    for t in ts.results
        if !t.result
            return 1
        end
    end
    return 0
end

macro jtestset(args...)
    isempty(args) && error("No arguments to @testset")
    tests = Array(args[end].args)
    quote
        evaluate_tests([$(esc.(tests)...)])
    end
end

include("xml.jl")

end # module
