using ParserCombinator

include("ast.jl")
include("ast2cnf.jl")

function create_ast(io::IO)::AstNode
  ws = Drop(Star(Space()))
  mws = Drop(Plus(Space()))
  variable_pattern = p"[a-zA-Z][a-zA-Z0-9]*"

  n_variable = variable_pattern > VariableNode

  n_formula = Delayed()

  left_parenthesis = Alt!(E"(", Error("Expected '('"))
  right_parenthesis = Alt!(E")", Error("Expected ')'"))

  n_compound_begin = Seq!(left_parenthesis, ws)
  n_compound_end = Seq!(ws, right_parenthesis)

  n_and = Seq!(E"and", mws, n_formula, mws, n_formula) > AndNode
  n_or = Seq!(E"or", mws, n_formula, mws, n_formula) > OrNode
  n_not = Seq!(E"not", mws, variable_pattern) > NotNode

  n_compound_inner = Alt!(n_and, n_or, n_not)

  n_compound = Seq!(n_compound_begin, n_compound_inner, n_compound_end)

  e_formula = Error("Expected an identifier or '('")
  n_formula.matcher = Alt!(n_variable, n_compound, e_formula)

  parse_try(io, n_formula)[1]
end

"""
    parse_nnf_formula(io::IO; <keyword arguments>)::Ast2CnfResult

Reads a formula in negation normal form from `io` and returns the same formula in CNF.
The conversion is implemented using Tseytin encoding.

# Arguments
- `only_left_to_right:Bool=false`: only generate left to right implications in Tseytin encoding.

See also [`Ast2CnfResult`](@ref).
"""
function parse_nnf_formula(io::IO; only_left_to_right=false)::Ast2CnfResult
  ast = create_ast(io)
  ast2cnf(ast, only_left_to_right=only_left_to_right)
end
