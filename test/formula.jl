import SatSolver: is_clause_satisfied, is_clause_unit, PartialAssignment,
  determine_variable_count, is_clause_falsified, find_unit_literal

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

  @testset "Is clause satisfied" begin
    cl = Clause(1, 4, -6)
    function test_case(pa::PartialAssignment, ref::Bool)
      @test is_clause_satisfied(cl, pa) == ref
    end

    pa = PartialAssignment(6)
    test_case(pa, false)
    pa[1] = 1
    test_case(pa, true)
    pa[1] = 0
    pa[4] = -1
    test_case(pa, false)
    pa[1] = -1
    test_case(pa, false)
    pa[6] = 1
    test_case(pa, false)
    pa[6] = -1
    test_case(pa, true)

    cl = Clause(-1, 2)
    test_case(PartialAssignment([-1, 1]), true)
    test_case(PartialAssignment([-1, -1]), true)
    test_case(PartialAssignment([-1, 0]), true)
    test_case(PartialAssignment([0, -1]), false)
    test_case(PartialAssignment([0, 0]), false)
    test_case(PartialAssignment([0, 1]), true)
    test_case(PartialAssignment([1, -1]), false)
    test_case(PartialAssignment([1, 0]), false)
    test_case(PartialAssignment([1, 1]), true)
  end

  @testset "Is clause falsified" begin
    cl = Clause(1, -2)
    function test_case(pa, ref)
      @test ref == is_clause_falsified(cl, PartialAssignment(pa))
    end

    test_case([-1, 1], true)
    test_case([-1, -1], false)
    test_case([-1, 0], false)
    test_case([0, -1], false)
    test_case([0, 0], false)
    test_case([0, 1], false)
    test_case([1, -1], false)
    test_case([1, 0], false)
    test_case([1, 1], false)
  end

  @testset "Is clause unit" begin
    function test_case(cl::Clause, pa::PartialAssignment, ref::Bool)
      @test ref == is_clause_unit(cl, pa)
    end

    cl = Clause(1, 2, -3)
    pa = PartialAssignment(3)
    test_case(cl, pa, false)
    pa[1] = 1
    test_case(cl, pa, false)
    pa[1] = -1
    pa[3] = 1
    test_case(cl, pa, true)
  end

  @testset "Find unit literal in a clause" begin
    cl = Clause(-1, 2)
    function test_case(pa, ref)
      @test ref == find_unit_literal(cl, PartialAssignment(pa))
    end

    test_case([-1, 1], 0)
    test_case([-1, -1], 0)
    test_case([-1, 0], 0)
    test_case([0, -1], -1)
    test_case([0, 0], 0)
    test_case([0, 1], 0)
    test_case([1, -1], 0)
    test_case([1, 0], 2)
    test_case([1, 1], 0)
  end
end
