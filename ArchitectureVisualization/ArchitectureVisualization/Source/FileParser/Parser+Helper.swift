import Foundation
import SwiftSyntax
import SwiftParser

func parseSwiftFiles(fileContents: [String]) -> [SwiftNode] {
    let astNodes = fileContents.flatMap { parseSwiftFile($0) }

    var preliminaryNodes: [SwiftNode] = astNodes.compactMap { ast in
        switch ast {
        case .class, .struct, .protocol:
            return SwiftNode(from: ast, allNodes: [])
        default:
            return nil
        }
    }

    preliminaryNodes = preliminaryNodes.map { node in
        SwiftNode(
            name: node._name,
            type: node.type,
            conformsTo: node.conformsTo,
            properties: node.properties,
            functions: node.functions,
            relationships: buildRelationships(for: node, in: preliminaryNodes)
        )
    }

    return preliminaryNodes
}

func parseSwiftFile(_ content: String) -> [ASTNode] {
    let sourceFile = Parser.parse(source: content)
    let visitor = SwiftASTVisitor(viewMode: .sourceAccurate)
    visitor.walk(sourceFile)
    return visitor.astNodes
}

class SwiftASTVisitor: SyntaxVisitor {
    var astNodes: [ASTNode] = []

    private var currentClassName: String?
    private var currentStructName: String?
    private var currentProtocolName: String?
    private var currentMembers: [ASTNode] = []

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        currentClassName = node.identifier.text
        currentMembers = []

        let inherits = node.inheritanceClause?.inheritedTypes.map {
            $0.type.trimmedDescription
        } ?? []

        defer {
            if let name = currentClassName {
                astNodes.append(.class(name: name, inherits: inherits, members: currentMembers))
            }
            currentClassName = nil
            currentMembers = []
        }

        return .visitChildren
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        currentStructName = node.identifier.text
        currentMembers = []

        defer {
            if let name = currentStructName {
                astNodes.append(.struct(name: name, members: currentMembers))
            }
            currentStructName = nil
            currentMembers = []
        }

        return .visitChildren
    }

    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        currentProtocolName = node.identifier.text
        currentMembers = []

        let inherits = node.inheritanceClause?.inheritedTypes.map {
            $0.type.trimmedDescription
        } ?? []

        defer {
            if let name = currentProtocolName {
                astNodes.append(.protocol(name: name, inherits: inherits, members: currentMembers))
            }
            currentProtocolName = nil
            currentMembers = []
        }

        return .visitChildren
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let binding = node.bindings.first,
              let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
              let typeAnnotation = binding.typeAnnotation else { return .skipChildren }

        let propertyName = pattern.identifier.text
        let propertyType = typeAnnotation.type.trimmedDescription

        let propertyNode: ASTNode = .property(name: propertyName, type: propertyType)

        if currentClassName != nil || currentStructName != nil || currentProtocolName != nil {
            currentMembers.append(propertyNode)
        }

        return .skipChildren
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        let functionName = node.identifier.text
        let returnType = node.signature.output?.returnType.trimmedDescription ?? "Void"

        let parameters = node.signature.input.parameterList.map { param in
            let paramName = param.firstName.text.isEmpty ? "_" : param.firstName.text
            let paramType = param.type.trimmedDescription ?? "Unknown"
            return (name: paramName, type: paramType)
        }

        let functionNode: ASTNode = .function(name: functionName, parameters: parameters, returnType: returnType)

        if currentClassName != nil || currentStructName != nil || currentProtocolName != nil {
            currentMembers.append(functionNode)
        }

        return .skipChildren
    }
}

private extension TypeSyntax {
    var trimmedDescription: String {
        self.description.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
