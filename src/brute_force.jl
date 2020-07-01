"""
    brute_force(fla::Formula)::SatSolverResult

Tries all possible variable assignments and stops at the first satisfying assignment.
"""
function brute_force(fla::Formula)::SatSolverResult
  pa = PartialAssignment(fill(-1, fla.variable_count))

  while true
    if all((cl) -> is_clause_satisfied(cl, pa), fla)
      return SatisfiableFormula(pa)
    end

    last_negative = findlast(pa.assignment) do x
      -1 == x
    end

    if nothing == last_negative
      break
    end

    pa[last_negative] = 1
    for i in (last_negative + 1):fla.variable_count
      pa[i] = -1
    end
  end

  UnsatisfiableFormula()
end
