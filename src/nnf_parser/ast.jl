abstract type AstNode end

struct VariableNode <: AstNode
  identifier::String
end

struct AndNode <: AstNode
  lhs::AstNode
  rhs::AstNode
end

struct OrNode <: AstNode
  lhs::AstNode
  rhs::AstNode
end

struct NotNode <: AstNode
  identifier::String
end
