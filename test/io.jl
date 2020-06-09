@testset "I/O" begin
  c0 = Clause(Int[])
  c1 = Clause(1, 2, -3)
  c1_ref = "(-3 ∨ 1 ∨ 2)"
  c2 = Clause(4, 2, 3)
  c2_ref = "(2 ∨ 3 ∨ 4)"
  c3 = Clause(999)
  c3_ref = "(999)"
  c4 = Clause(-123)

  @testset "Pretty printing of clauses" begin
    function test_case(cl::Clause, ref::String)
      io = IOBuffer()
      print(io, cl)
      res = String(take!(io))
      @test res == ref
      close(io)
    end

    test_case(c0, "()")
    test_case(c1, c1_ref)
    test_case(c2, c2_ref)
    test_case(c3, c3_ref)
    test_case(c4, "(-123)")
  end

  f0 = Formula()
  f1 = Formula(c1)
  f2 = Formula(c1, c2, c3)

  @testset "Pretty printing of formulas" begin
    function test_case(fla::Formula, ref::String)
      io = IOBuffer()
      print(io, fla)
      res = String(take!(io))
      @test res == ref
      close(io)
    end

    test_case(f0, "()")
    test_case(f1, "($c1_ref)")
    test_case(f2, "($c1_ref ∧ $c2_ref ∧ $c3_ref)")
  end
end
