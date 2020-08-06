"""
    unit_propagation!(fla::Formula, pa::PartialAssignment)::Bool

Performs unit propagation on `fla` and modifies `pa` to add the implied values.
Returns `false` if conflict is reached.

TODO: Implement using watched literals.
"""
function unit_propagation!(fla::Formula, pa::PartialAssignment)::Bool
  function exists_falsified_clause()
    any((cl) -> is_clause_falsified(cl, pa), fla)
  end

  while true
    (l, _)  = find_unit_literal(fla, pa)
    if 0 == l
      break
    end

    pa[abs(l)] = sign(l)
    if exists_falsified_clause()
      return false
    end
  end

  !exists_falsified_clause()
end

"""
See [`BcpNoConflict`](@ref) and [`BcpConflict`](@ref).
"""
abstract type BcpResult end

"""
Returns literals implied by `bcp!` in order of their implication.
"""
function bcp_get_implied_literals(bcpRes::BcpResult)::Vector{Int}
  return bcpRes.implied_literals
end

"""
If `bcp!` did not reach a conflict, then a result of type `BcpNoConflict` is
returned.
"""
struct BcpNoConflict <: BcpResult
  implied_literals::Vector{Int}
end

function bcp_found_conflict(bcpRes::BcpNoConflict)
  false
end

"""
If `bcp!` reached a conflict, then a result of type `BcpNoConflict` is returned.
Property `conflict_clause_i` contains the index of the conflicting clause of
the `Formula` passed to `bcp!`.
"""
struct BcpConflict <: BcpResult
  implied_literals::Vector{Int}
  conflict_clause_i::Int
end

function bcp_found_conflict(bcpRes::BcpConflict)
  true
end

"""
Returns the index (in the formula passed to `bcp!`) of the conflict clause
found by `bcp!`.
"""
function bcp_get_conflict_clause_index(bcpRes::BcpConflict)
  return bcpRes.conflict_clause_i
end

"""
    bcp!(fla::Formula, pa::PartialAssignment, ante::Vector{Int})::BcpResult

Performs unit propagation on `fla`, modifies the partial assignment `pa` and
sets antecedents `ante`.
Returns a tuple: the first entry contains a vector of implied literals ordered
by their implication order. If the second entry is not no
reached.

See also [`BcpResult`](@ref).
"""
function bcp!(fla::Formula,
              pa::PartialAssignment,
              ante::Vector{Int},
              dl::Number,
              decision_level::Vector{Int})::Tuple{Vector{Int}, Bool}
  function find_falsified_clause()
    findfirst((cl) -> is_clause_falsified(cl, pa), fla)
  end

  implied_literals = Vector{Int}()

  while true
    (l, cl_i) = find_unit_literal(fla, pa)
    if 0 == l
      break
    end

    push!(implied_literals, l)
    v = abs(l)
    pa[v] = sign(l)
    ante[v] = cl_i
    decision_level[v] = dl
    
    falsified_clause_i = find_falsified_clause()
    if nothing != falsified_clause_i
      return BcpConflict(implied_literals, falsified_clause_i)
    end
  end

  falsified_clause_i = find_falsified_clause()
  if nothing != falsified_clause_i
    return BcpConflict(implied_literals, falsified_clause_i)
  else
    return BcpNoConflict(implied_literals)
  end
end
