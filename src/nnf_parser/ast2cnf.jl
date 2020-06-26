mutable struct Ast2CnfResult
  """
  `identifier_dict` is a dictionary which maps original variable identifiers to variables in the resulting CNF formula.
  """
  identifier_dict::Dict{String, UInt}
  """
  Number of variables in the resulting formula.
  """
  variable_count::UInt
  only_left_to_right::Bool
  clauses::Vector{Clause}
end

function Ast2CnfResult(only_left_to_right::Bool)
  Ast2CnfResult(
    Dict{String, UInt}(),
    0,
    only_left_to_right,
    Clause[]
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
  single_lit = ast2cnf!(res, root)

  if 0 == length(res.clauses)
    res.clauses = [Clause(single_lit)]
  end

  res
end

function identifier_to_variable!(res::Ast2CnfResult, identifier::String)::UInt
  get!(res.identifier_dict, identifier) do
    res.variable_count += 1
  end
end

function ast2cnf!(res::Ast2CnfResult, node::VariableNode)::Int
  identifier_to_variable!(res, node.identifier)
end

function ast2cnf!(res::Ast2CnfResult, node::NotNode)::Int
  -signed(identifier_to_variable!(res, node.identifier))
end

"""
    extract_binary_conjunctive(res::Ast2CnfResult, node::AstNode)::Tuple{Int, Int, Int}

Returns literals for LHS and RHS of `node` and the literal of `node` (in this order).
"""
function extract_binary_conjunctive!(res::Ast2CnfResult,
                                     node::AstNode)::Tuple{Int, Int, Int}
  lhs::Int = ast2cnf!(res, node.lhs)
  rhs::Int = ast2cnf!(res, node.rhs)
  clause_identifier = res.variable_count += 1

  lhs, rhs, clause_identifier
end

function ast2cnf!(res::Ast2CnfResult, node::AndNode)::UInt
  lhs::Int, rhs::Int, cl_id::Int = extract_binary_conjunctive!(res, node)

  push!(res.clauses, Clause(-cl_id, lhs))
  push!(res.clauses, Clause(-cl_id, rhs))
  if !res.only_left_to_right
    push!(res.clauses, Clause(cl_id, -lhs, -rhs))
  end

  cl_id
end

function ast2cnf!(res::Ast2CnfResult, node::OrNode)::UInt
  lhs::Int, rhs::Int, cl_id::Int = extract_binary_conjunctive!(res, node)

  push!(res.clauses, Clause(-cl_id, lhs, rhs))
  if !res.only_left_to_right
    push!(res.clauses, Clause(cl_id, -lhs))
    push!(res.clauses, Clause(cl_id, -rhs))
  end

  cl_id
end
