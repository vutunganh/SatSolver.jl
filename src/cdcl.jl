function pick_branching_literal(fla::Formula, pa::PartialAssignment)::Int
  fla
  var = findfirst((x) -> 0 == x, pa)
  -var
end

function clause_has_implied_literal(cl::Clause,
                                    l::Int,
                                    ante::Vector{Int},
                                    dl::Int,
                                    decision_level::Vector{Int})
  v = abs(l)
  return l in cl && decision_level[v] == dl && ante[v] != 0
end

function resolve(cl1::Clause, cl2::Clause, var::Int)::Clause
  f = (l) -> l != var && -l != var
  [filter(f, cl1); filter(f, cl2)]
end

"""
    resolution_step(cl1::Clause, cl2::Clause)::Clause

Performs a resolution step of clauses `cl1` and `cl2`. This function assumes
that the input is valid for resolution, i.e. `cl1` and `cl2` share exactly one
variable and it appears with opposing polarities in `cl1` and `cl2`. If this
prerequisite is not met, the output is undefined.
"""
function resolution_step(cl1::Clause, cl2::Clause)::Clause
  for l in cl1
    if l in cl2
      return resolve(cl1, cl2, abs(l))
    end
  end
  print(stderr, "Tried to resolve clauses without a common variable ", cl1, ", ", cl2)
end

"""
    find_1uip(fla::Formula, conflict_cl_i::Int,
              implied_literals::Vector{Int}, ante::Vector{Int}, dl::Int,
              decision_level::Vector{Int})::Clause

Finds a 1-uip given conflict clause `fla[conflict_cl_i]`.
"""
function find_1uip(fla::Formula, conflict_cl_i::Int,
                   implied_literals::Vector{Int}, ante::Vector{Int}, dl::Int,
                   decision_level::Vector{Int})::Clause
  function lits_on_cur_dl(cl::Clause)
    count(cl) do l
      decision_level[abs(l)] == dl
    end
  end

  res = fla[conflict_cl_i]
  resolution_steps_performed = 0
  while lits_on_cur_dl(res) > 1
    ante_i = ante[implied_literals[end - resolution_steps_performed]]
    res = resolution_step(res, fla[ante_i])
    resolution_steps_performed += 1
  end
  res
end

function conflict_analysis(fla::Formula,
                           pa::PartialAssignment,
                           dl::Number,
                           stop_criterion)
  if 0 == dl
    return -1
  end
  
  cl = findfirst(cl -> is_clause_falsified(cl, pa), fla)
  while !stop_criterion(cl)

  end
end

"""
    find_assertion_lvl(asserting_clause::Clause, decision_level::Vector{Int})
    
Given an asserting clause returns the assertion level.

TODO: Implement in constant space.
"""
function find_assertion_lvl(asserting_clause::Clause, decision_level::Vector{Int})
  dls = [decision_level[abs(l)] for l in asserting_clause]
  sort!(dls)
  unique!(dls)
  dls[end - 1]
end

function analyse_conflict!(fla::Formula, dl::Int, conflict_cl_i::UInt,
                           implied_literals::Vector{Int}, ante::Vector{UInt},
                           decision_level::Vector{Int})::Int
  asserting_clause = find_1uip(fla, conflict_cl_i, implied_literals, ante,
                               dl, decision_level)
  push!(fla, asserting_clause)
  find_assertion_lvl(asserting_clause, decision_level)
end

function backtrack!(pa::PartialAssignment,
                    ante::Vector{Int},
                    decision_level::Vector{Int},
                    backtrack_level::Int)
  for (l, d) in enumerate(decision_level)
    if d <= backtrack_level
      continue
    end

    v = abs(l)
    pa[v] = 0
    ante[v] = 0
    decision_level[v] = -1
  end
end

# TODO: Function for branching variable decision as a parameter.
"""
    cdcl(fla::Formula; <keyword arguments>)

Performs CDCL SAT solving procedure.

# Arguments:
- `pick_branching_literal`: a custom function for selecting the next branching
literal. It receives the formula's clauses (including all learned clauses) and
the current `PartialAssignment` and should return a picked literal.
"""
function cdcl(fla::Formula; pick_branching_literal=pick_branching_literal)
  clause_count = size(fla)
  var_count = fla.variable_count
  pa = PartialAssignment(var_count)
  ante = zeros(clause_count)
  decision_level = -ones(var_count)

  dl = 0
  while !all_variables_assigned(pa)
    l = pick_branching_literal(fla, pa)
    x = abs(l)
    v = sign(l)
    dl += 1
    pa[x] = v
    bcpRes = bcp!(fla, pa, ante, dl, decision_level)

    if !bcp_found_conflict(bcpRes)
      continue
    end

    backtrack_lvl = analyse_conflict!(fla, dl,
                                      bcp_get_conflict_clause_index(bcpRes),
                                      bcp_get_implied_literals(bcpRes), ante,
                                      decision_level)
    if backtrack_lvl < 0
      return UnsatisfiableFormula()
    end

    backtrack!(pa, ante, decision_level, backtrack_lvl)
    dl = backtrack_lvl
  end

  SatisfiableFormula(pa)
end
