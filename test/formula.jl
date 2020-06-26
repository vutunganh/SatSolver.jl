import SatSolver: is_clause_satisfied, is_clause_unit, PartialAssignment,
  determine_variable_count

@testset "Formula" begin
  @testset "Determine variable count from a vector of clauses" begin
    function test_case(clauses::Vector{Clause}, ref)
      @test determine_variable_count(clauses) == ref
    end

    test_case(Clause[Clause(-1)], 1)
    test_case(Clause[Clause(-2)], 2)
    test_case(Clause[Clause(2)], 2)
    test_case(Clause[Clause(2), Clause(40)], 40)
  end
end
