import Foundation

class SwiftNode: Equatable, Hashable, Identifiable {
    var id = UUID()
    var _name: String
    var type: SwiftNodeType
    var conformsTo: [String] = []
    var properties: [SwiftProperty] = []
    var functions: [SwiftFunction] = []
    var relationships: [SwiftRelationship] = []

    init(
        name: String,
        type: SwiftNodeType,
        conformsTo: [String],
        properties: [SwiftProperty] = [],
        functions: [SwiftFunction] = [],
        relationships: [SwiftRelationship] = []
    ) {
        self._name = name
        self.type = type
        self.conformsTo = conformsTo
        self.properties = properties
        self.functions = functions
        self.relationships = relationships
    }

    var name: String {
        (_name as NSString).deletingPathExtension
    }

    static func == (lhs: SwiftNode, rhs: SwiftNode) -> Bool {
        lhs.name == rhs.name
        && lhs.type == rhs.type
        && lhs.conformsTo == rhs.conformsTo
        && lhs.properties == rhs.properties
        && lhs.functions == rhs.functions
        && lhs.relationships == rhs.relationships
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(conformsTo)
        hasher.combine(properties)
        hasher.combine(functions)
        hasher.combine(relationships)
    }

    static func nodes(from content: String) -> [SwiftNode] {
        let astNodes = parseSwiftFile(content)
        return astNodes.map { SwiftNode(from: $0) }
    }
}

extension SwiftNode {
    convenience init(from ast: ASTNode) {
        switch ast {
        case let .class(name, inherits, members):
            let properties = members.compactMap { ast -> SwiftProperty? in
                if case let .property(name, _) = ast {
                    return SwiftProperty(name: name)
                }
                return nil
            }
            let functions = members.compactMap { ast -> SwiftFunction? in
                if case let .function(name, _, _) = ast {
                    return SwiftFunction(name: name)
                }
                return nil
            }
            let relationships = members.flatMap {
                SwiftRelationship.from(ast: $0, parent: name)
            }

            self.init(
                name: name,
                type: .class,
                conformsTo: inherits,
                properties: properties,
                functions: functions,
                relationships: relationships
            )

        case let .struct(name, members):
            let properties = members.compactMap { ast -> SwiftProperty? in
                if case let .property(name, _) = ast {
                    return SwiftProperty(name: name)
                }
                return nil
            }
            let functions = members.compactMap { ast -> SwiftFunction? in
                if case let .function(name, _, _) = ast {
                    return SwiftFunction(name: name)
                }
                return nil
            }
            let relationships = members.flatMap {
                SwiftRelationship.from(ast: $0, parent: name)
            }

            self.init(
                name: name,
                type: .struct,
                conformsTo: [],
                properties: properties,
                functions: functions,
                relationships: relationships
            )

        default:
            self.init(name: "Anonymous", type: .unknown, conformsTo: [])
        }
    }
}
