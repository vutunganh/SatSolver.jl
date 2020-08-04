import Base: ==, setindex!, copy

readonly_vector_wrapper_functions = (:getindex, :firstindex, :lastindex, :iterate, :length, :size, :keys)

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
  variable_count::UInt
  clauses::Vector{Clause}
end

function determine_variable_count(clauses::Vector{Clause})::UInt
  maximum(clauses) do cl
    maximum(abs, cl)
  end
end

Formula(clauses::Vector{Clause}) = Formula(determine_variable_count(clauses),
                                           clauses)
Formula(clauses::Vararg{Clause}) = Formula([clauses...])
Formula(var_count) = Formula(var_count, [])

for f in readonly_vector_wrapper_functions
  @eval Base.$f(fla::Formula, args...) = Base.$f(fla.clauses, args...)
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

struct PartialAssignment
  assignment::Vector{Int8}
end

PartialAssignment(n::Number) = PartialAssignment(zeros(Int8, n))

for f in readonly_vector_wrapper_functions
  @eval Base.$f(pa::PartialAssignment, args...) = Base.$f(pa.assignment, args...)
end

function setindex!(pa::PartialAssignment, value::T, key) where {T <: Integer}
  @assert -1 <= value <= 1
  pa.assignment[key] = value
end

function ==(pa1::PartialAssignment, pa2::PartialAssignment)
  pa1.assignment == pa2.assignment
end

function copy(pa::PartialAssignment)
  PartialAssignment(copy(pa.assignment))
end

function is_clause_satisfied(cl::Clause, pa::PartialAssignment)
  any(cl) do l
    sign(l) == pa[abs(l)]
  end
end

function is_literal_undecided(l::Int, pa::PartialAssignment)::Bool
  0 == pa[abs(l)]
end

"""
    clause_size(cl::Clause, pa::PartialAssignment)

Counts the number of unsatisfied literals in `cl` with respect to partial
assignment `pa`. If `cl` is satisfied, returns 0.

See also: [`Clause`](@ref), [`PartialAssignment`](@ref).
"""
function clause_size(cl::Clause, pa::PartialAssignment)
  if is_clause_satisfied(cl, pa)
    return 0
  end

  count((l) -> is_literal_undecided(l, pa), cl)
end

function is_clause_unit(cl::Clause, pa::PartialAssignment)
  1 == clause_size(cl, pa)
end

"""
    is_clause_falsified(cl::Clause, pa::PartialAssignment)::Bool

Returns true if all literals of `cl` are decided and `cl` is not satisfied.
"""
function is_clause_falsified(cl::Clause, pa::PartialAssignment)::Bool
  !is_clause_satisfied(cl, pa) && 0 == clause_size(cl, pa)
end

"""
    find_unit_literal(cl::Clause, pa::PartialAssignment)

If `cl` is a unit clause, returns the “unit literal”, otherwise returns 0.

See also: [`PartialAssignment`](@ref)
"""
function find_unit_literal(cl::Clause, pa::PartialAssignment)::Int
  if !is_clause_unit(cl, pa)
    return 0
  end

  cl[findfirst((l) -> is_literal_undecided(l, pa), cl)]
end

function find_unit_literal(fla::Formula, pa::PartialAssignment)
  for cl in fla
    tmp = find_unit_literal(cl, pa)
    if 0 != tmp
      return tmp
    end
  end

  0
end

abstract type SatSolverResult end

struct SatisfiableFormula <: SatSolverResult
  satisfying_assignment::PartialAssignment
end

struct UnsatisfiableFormula <: SatSolverResult
end

function is_formula_satisfiable(res::SatisfiableFormula)
  true
end

function is_formula_satisfiable(res::UnsatisfiableFormula)
  false
end
