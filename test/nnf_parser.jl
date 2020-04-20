import SatSolver: AstNode, VariableNode, NotNode, AndNode, OrNode, create_ast,
                  ast2cnf, add_clause!

@testset "NNF formula parser" begin
  function create_test_case(input, reference)
    buffer = IOBuffer(input)
    ast = create_ast(buffer)
    @test ast == reference
  end

  create_test_case("a", VariableNode("a"))
  create_test_case("(not a)", NotNode("a"))
  create_test_case("(and a b)", AndNode(VariableNode("a"), VariableNode("b")))
  create_test_case("(and (not a) b)", AndNode(NotNode("a"), VariableNode("b")))
  create_test_case("(and (or (not a) b) (and b c))",
                   AndNode(OrNode(NotNode("a"), VariableNode("b")),
                           AndNode(VariableNode("b"), VariableNode("c"))))
end

@testset "Ast2Cnf" begin
  function create_test_case(ast::T, clauses::Vector{Clause}, olr::Bool=false) where {T <: AstNode}
    res = ast2cnf(ast, only_left_to_right=olr)
    fla = Formula(clauses...)
    @test res.result == fla
  end

  create_test_case(VariableNode("a"), [Clause(1)])
  create_test_case(NotNode("a"), [Clause(-1)])
  create_test_case(AndNode(VariableNode("a"), NotNode("b")),
                   [Clause(-3, 1), Clause(-3, -2), Clause(-1, 2, 3)])
  create_test_case(AndNode(VariableNode("a"), NotNode("b")),
                   [Clause(-3, 1), Clause(-3, -2)],
                   true)
  create_test_case(OrNode(VariableNode("c"),
                          AndNode(VariableNode("a"), VariableNode("b"))),
                   [Clause(-4, 2), Clause(-4, 3), Clause(-2, -3, 4), Clause(-5, 1, 4),
                    Clause(-1, 5), Clause(-4, 5)])
end
