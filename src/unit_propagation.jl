# TODO: Implement using adjacency lists.
# TODO: Implement using watched literals.
function unit_propagation!(fla::Formula, pa::PartialAssignment)::Bool
  while true
    l = find_unit_literal(fla, pa)
    if 0 == l
      break
    end

    pa[abs(l)] = sign(l)
    if any((cl) -> is_clause_falsified(cl, pa), fla)
      return false
    end
  end

  return !any((cl) -> is_clause_falsified(cl, pa), fla)
end
