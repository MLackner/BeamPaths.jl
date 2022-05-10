using BeamPaths
using Test
using Revise

entr(["./test/testpath.jl"], [BeamPaths]) do
    include(joinpath(@__DIR__, "testpath.jl"))
end