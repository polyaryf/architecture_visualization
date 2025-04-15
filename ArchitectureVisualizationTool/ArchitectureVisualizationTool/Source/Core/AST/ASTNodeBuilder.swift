//
//  ASTNodeBuilder.swift
//  ArchitectureVisualizationTool
//
//  Created by Полина Рыфтина on 12.04.2025.
//

import SwiftSyntax

class ASTNodeBuilder: SyntaxVisitor {

    // MARK: - Результаты

    private(set) var classes: [String: ClassNode] = [:]
    private(set) var structs: [String: StructNode] = [:]
    private(set) var enums: [String: EnumNode] = [:]

    // MARK: - Контекст обхода

    private var currentTypeName: String?
    private var currentTypeKind: TypeKind?

    override init(viewMode: SyntaxTreeViewMode = .sourceAccurate) {
        super.init(viewMode: viewMode)
    }

    // MARK: - Вход в декларации

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        let name = node.name.text
        let protocols = node.inheritanceClause?.inheritedTypes.map { $0.type.trimmedDescription } ?? []

        var classNode = classes[name] ?? ClassNode(name: name)
        classNode.protocols.append(contentsOf: protocols)
        classes[name] = classNode

        currentTypeName = name
        currentTypeKind = .class

        return .visitChildren
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        let name = node.name.text
        let protocols = node.inheritanceClause?.inheritedTypes.map { $0.type.trimmedDescription } ?? []

        var structNode = structs[name] ?? StructNode(name: name)
        structNode.protocols.append(contentsOf: protocols)
        structs[name] = structNode

        currentTypeName = name
        currentTypeKind = .struct

        return .visitChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        let name = node.name.text
        let protocols = node.inheritanceClause?.inheritedTypes.map { $0.type.trimmedDescription } ?? []

        var enumNode = enums[name] ?? EnumNode(name: name)
        enumNode.protocols.append(contentsOf: protocols)
        enums[name] = enumNode

        currentTypeName = name
        currentTypeKind = .enum

        return .visitChildren
    }

    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let extendedType = node.extendedType.as(IdentifierTypeSyntax.self) else {
            return .skipChildren
        }

        let name = extendedType.name.text
        let protocols = node.inheritanceClause?.inheritedTypes.map { $0.type.trimmedDescription } ?? []

        if var classNode = classes[name] {
            classNode.protocols.append(contentsOf: protocols)
            classes[name] = classNode
            currentTypeKind = .extension(originalType: name)
        } else if var structNode = structs[name] {
            structNode.protocols.append(contentsOf: protocols)
            structs[name] = structNode
            currentTypeKind = .extension(originalType: name)
        } else if var enumNode = enums[name] {
            enumNode.protocols.append(contentsOf: protocols)
            enums[name] = enumNode
            currentTypeKind = .extension(originalType: name)
        } else {
            currentTypeKind = nil
        }

        currentTypeName = name
        return .visitChildren
    }

    // MARK: - Выход из деклараций

    func visitPost(_ node: DeclSyntaxProtocol) {
        if node.is(ClassDeclSyntax.self) ||
            node.is(StructDeclSyntax.self) ||
            node.is(EnumDeclSyntax.self) ||
            node.is(ExtensionDeclSyntax.self) {
            currentTypeName = nil
            currentTypeKind = nil
        }
    }

    // MARK: - Свойства

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let currentTypeName = currentTypeName else { return .skipChildren }

        let propertyNodes: [PropertyNode] = node.bindings.compactMap { binding in
            guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
                  let typeAnnotation = binding.typeAnnotation else {
                return nil
            }

            let propertyName = pattern.identifier.text
            let propertyType = typeAnnotation.type.trimmedDescription
            
            // Определяем ownership
            let ownership: Ownership
            if node.modifiers.contains(where: { $0.name.text == "weak" }) == true {
                ownership = .weak
            } else if node.modifiers.contains(where: { $0.name.text == "unowned" }) == true {
                ownership = .unowned
            } else {
                ownership = .strong
            }
            
            return PropertyNode(name: propertyName, type: propertyType, ownership: ownership)
        }
        
        switch currentTypeKind {
        case .class:
            var classNode = classes[currentTypeName]!
            classNode.properties.append(contentsOf: propertyNodes)
            classes[currentTypeName] = classNode

        case .extension(let originalType):
            if var classNode = classes[originalType] {
                classNode.properties.append(contentsOf: propertyNodes)
                classes[originalType] = classNode
            } else if var structNode = structs[originalType] {
                structNode.properties.append(contentsOf: propertyNodes)
                structs[originalType] = structNode
            } else if var enumNode = enums[originalType] {
                enumNode.properties.append(contentsOf: propertyNodes)
                enums[originalType] = enumNode
            }

        case .struct:
            var structNode = structs[currentTypeName]!
            structNode.properties.append(contentsOf: propertyNodes)
            structs[currentTypeName] = structNode

        case .enum:
            var enumNode = enums[currentTypeName]!
            enumNode.properties.append(contentsOf: propertyNodes)
            enums[currentTypeName] = enumNode

        case .none:
            break
        }

        return .skipChildren
    }

    // MARK: - Функции

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let currentTypeName = currentTypeName else { return .skipChildren }

        let functionName = node.name.text

        switch currentTypeKind {
        case .class:
            var classNode = classes[currentTypeName]!
            classNode.functions.append(functionName)
            classes[currentTypeName] = classNode

        case .struct:
            var structNode = structs[currentTypeName]!
            structNode.functions.append(functionName)
            structs[currentTypeName] = structNode

        case .enum:
            var enumNode = enums[currentTypeName]!
            enumNode.functions.append(functionName)
            enums[currentTypeName] = enumNode
        
        case .extension(let originalType):
            if var classNode = classes[originalType] {
                classNode.functions.append(functionName)
                classes[originalType] = classNode
            } else if var structNode = structs[originalType] {
                structNode.functions.append(functionName)
                structs[originalType] = structNode
            } else if var enumNode = enums[originalType] {
                enumNode.functions.append(functionName)
                enums[originalType] = enumNode
            }
        
        default:
            break
        }

        return .skipChildren
    }

    // MARK: - Cases enum

    override func visit(_ node: EnumCaseElementSyntax) -> SyntaxVisitorContinueKind {
        guard let currentTypeName = currentTypeName, case .enum = currentTypeKind else { return .skipChildren }

        var enumNode = enums[currentTypeName]!
        enumNode.cases.append(node.name.text)
        enums[currentTypeName] = enumNode

        return .skipChildren
    }
}
