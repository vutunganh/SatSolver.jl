mutable struct Ast2CnfResult
  """
  The formula will contain variables, which do not correspond to input variables.
  `identifier_dict` is a dictionary which maps original identifiers of input variables to variables in the resulting CNF formula.
  """
  identifier_dict::Dict{String, Int}
  """
  Number of variables in the resulting formula.
  """
  variable_count::Int
  only_left_to_right::Bool
  result::Formula
end

function Ast2CnfResult(only_left_to_right::Bool)
  Ast2CnfResult(
    Dict{String, Int}(),
    0,
    only_left_to_right,
    Formula()
  )
end

"""
    ast2cnf(root::AstNode; <keyword arguments>)::Ast2CnfResult

Converts a parsed formula in NNF into a formula in CNF.
Returns `Ast2CnfResult`.

# Arguments
- `only_left_to_right::Bool=false`: only generate left to right implications in Tseytin encoding.

See also [`Ast2CnfResult`](@ref).
"""
function ast2cnf(root::AstNode; only_left_to_right=false)::Ast2CnfResult
  res = Ast2CnfResult(only_left_to_right)
  ast2cnf!(res, root)
  res
end

function identifier_to_variable!(res::Ast2CnfResult, identifier::String)::Int
  identifier_dict::Dict{String, Int} = res.identifier_dict

  get!(identifier_dict, identifier) do
    res.variable_count += 1
  end
end

function ast2cnf!(res::Ast2CnfResult, node::VariableNode)::Int
  identifier_to_variable!(res, node.identifier)
end

function ast2cnf!(res::Ast2CnfResult, node::NotNode)::Int
  -identifier_to_variable!(res, node.identifier)
end

"""
    extract_binary_conjunctive(res::Ast2CnfResult, node::AstNode)::Tuple{Int, Int, Int}

Returns identifiers of LHS and RHS of `node` and identifier of `node` (in this order).
"""
function extract_binary_conjunctive!(res::Ast2CnfResult, node::AstNode)::Tuple{Int, Int, Int}
  lhs::Int = ast2cnf!(res, node.lhs)
  rhs::Int = ast2cnf!(res, node.rhs)
  clause_identifier = res.variable_count += 1

  lhs, rhs, clause_identifier
end

function ast2cnf!(res::Ast2CnfResult, node::AndNode)::Int
  lhs::Int,
  rhs::Int,
  clause_identifier::Int = extract_binary_conjunctive!(res, node)

  add_clause!(res.result, Clause(-clause_identifier, lhs))
  add_clause!(res.result, Clause(-clause_identifier, rhs))
  if !res.only_left_to_right
    add_clause!(res.result, Clause(clause_identifier, -lhs, -rhs))
  end

  clause_identifier
end

function ast2cnf!(res::Ast2CnfResult, node::OrNode)::Int
  lhs::Int,
  rhs::Int,
  clause_identifier::Int = extract_binary_conjunctive!(res, node)

  add_clause!(res.result, Clause(-clause_identifier, lhs, rhs))
  if !res.only_left_to_right
    add_clause!(res.result, Clause(clause_identifier, -lhs))
    add_clause!(res.result, Clause(clause_identifier, -rhs))
  end

  clause_identifier
end
