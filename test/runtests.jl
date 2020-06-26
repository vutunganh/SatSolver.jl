using SatSolver
using Test

@testset "SatSolver.jl" begin
  include("formula.jl")
  include("nnf_parser.jl")
  include("io.jl")
end
