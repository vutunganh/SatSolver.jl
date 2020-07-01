using SatSolver
using Test

include("utils.jl")

@testset "SatSolver.jl" begin
  include("formula.jl")
  include("nnf_parser.jl")
  include("io.jl")
  include("dpll.jl")
end
