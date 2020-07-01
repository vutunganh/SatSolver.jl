import SatSolver: dpll, brute_force, is_formula_satisfiable

@testset "DPLL algorithm" begin
  @testset "Random formulas" begin
    for _ in 1:500
      fla = gen_rand_formula(;
                             max_clauses=Unsigned(50),
                             max_variables=Unsigned(20),
                             max_clause_len=Unsigned(4))
      @test is_formula_satisfiable(dpll(fla)) == is_formula_satisfiable(brute_force(fla))
    end
  end
end
