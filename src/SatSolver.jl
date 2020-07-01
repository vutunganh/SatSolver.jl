module SatSolver

include("formula.jl")

export Clause, Formula, is_formula_satisfiable

include("nnf_parser/nnf_parser.jl")

export parse_nnf_formula

include("io.jl")

export print_dimacs_cnf

include("unit_propagation.jl")

include("brute_force.jl")
export brute_force

include("dpll.jl")
export dpll

end # module
