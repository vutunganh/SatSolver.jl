import Base.==, Base.show

"""
A clause is a set of (non-conflicting) literals.
Literal identifiers are number; positive literals correspond to positive numbers, negative literals to negative numbers.

A set of literals is represented by a sorted vector.
It follows that negative literals precede positive literals.
"""
struct Clause
  literals::Vector{Int}

  Clause(literals::Vector{Int}) = new(sort(literals))
end

Clause(literals::Vararg{Int}) = Clause([literals...])

for f in readonly_vector_wrapper_functions
  @eval Base.$f(cl::Clause, args...) = Base.$f(cl.literals, args...)
end

function ==(c1::Clause, c2::Clause)
  c1.literals == c2.literals
end

"""
A formula is a set of clauses.

A set of clauses is represented by a vector.
Unlike `Clause`, no sorting is being done.

See also: [`Clause`](@ref).
"""
struct Formula
  clauses::Vector{Clause}
end

Formula(clauses::Vararg{Clause}) = Formula([clauses...])

function add_clause!(formula::Formula, clause::Clause)
  push!(formula.clauses, clause)
end

function clause_count(formula::Formula)
  length(formula.clauses)
end

# TODO: Implement in subquadratic time.
function ==(f1::Formula, f2::Formula)
  for c1 in f1.clauses
    matched = false

    for c2 in f2.clauses
      if c1 == c2
        matched = true
        break
      end
    end

    if !matched
      return false
    end
  end

  return true
end
