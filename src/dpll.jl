function dpll(fla::Formula)::SatSolverResult
  pa = PartialAssignment(fla.variable_count)
  dpll_rec(fla, pa)
end

function dpll_rec(fla::Formula, pa::PartialAssignment)::SatSolverResult
  up = unit_propagation!(fla, pa)
  if false == up
    return UnsatisfiableFormula()
  end

  # Find an undecided variable.
  undecided_var = findfirst((v) -> 0 == v, pa)
  if nothing == undecided_var
    return SatisfiableFormula(pa)
  end

  new_pa = copy(pa)
  new_pa[undecided_var] = 1
  sol_true = dpll_rec(fla, new_pa)
  if is_formula_satisfiable(sol_true)
    return sol_true
  end

  new_pa = copy(pa)
  new_pa[undecided_var] = -1
  sol_false = dpll_rec(fla, new_pa)
  if is_formula_satisfiable(sol_false)
    return sol_false
  end

  UnsatisfiableFormula()
end
