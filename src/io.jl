import Base: show

function print_dimacs_cnf(io::IO, formula::Formula, root_var::Int)
  println(io, "p cnf ", root_var, " ", clause_count(formula))
  for clause in formula.clauses
    for literal in clause.literals
      print(io, literal, " ")
    end
    print(io, "0\n")
  end
end

function print_dimacs_cnf(io::IO, ast2cnf_res::Ast2CnfResult)
  print(io, "c Original variables:")
  for identifier in values(ast2cnf_res.identifier_dict)
    print(io, " ", identifier)
  end
  print(io, "\n")

  println(io, "c Root node variable: ", ast2cnf_res.variable_count)

  print_dimacs_cnf(io, ast2cnf_res.result, ast2cnf_res.variable_count)
end


function show(io::IO, cl::Clause)
  print(io, "(")
  if 0 == length(cl)
    print(io, ")")
    return
  end

  print(io, cl[1])
  @inbounds for i in 2:length(cl)
    print(io, " ∨ $(cl[i])")
  end
  print(io, ")")
end

function show(io::IO, fla::Formula)
  print(io, "(")
  if 0 == length(fla)
    print(io, ")")
    return
  end

  print(io, fla[1])
  @inbounds for i in 2:length(fla)
    print(io, " ∧ $(fla[i])")
  end
  print(io, ")")
end
