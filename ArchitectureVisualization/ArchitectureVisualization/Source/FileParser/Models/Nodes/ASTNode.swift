enum ASTNode {
    case `class`(name: String, inherits: [String], members: [ASTNode])
    case `struct`(name: String, members: [ASTNode])
    case `protocol`(name: String, inherits: [String], members: [ASTNode])
    case property(name: String, type: String)
    case function(name: String, parameters: [(name: String, type: String)], returnType: String)
}
