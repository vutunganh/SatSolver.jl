import SatSolver: cdcl, brute_force, is_formula_satisfiable, SatSolverResult

@testset "CDCL algorithm" begin
  function cdcl_test(fla::Formula, ref::SatSolverResult)
    cdcl_res = dpll(fla)
    correct_result = is_formula_satisfiable(cdcl_res) == is_formula_satisfiable(ref)
    if correct_result && is_formula_satisfiable(ref)
      @test correct_result && all((cl) -> is_clause_satisfied(cl, cdcl_res.satisfying_assignment), fla)
    else
      @test correct_result
    end
  end

  @testset "Random formulas" begin
    for _ in 1:500
      fla = gen_rand_formula(;
                             max_clauses=Unsigned(50),
                             max_variables=Unsigned(20),
                             max_clause_len=Unsigned(4))
      cdcl_test(fla, brute_force(fla))
    end
  end
end
