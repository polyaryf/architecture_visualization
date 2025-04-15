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

    /// 🎯 Новый метод для построения nodes с учетом связей через протоколы!
    static func nodes(from content: String, allNodes: [SwiftNode]) -> [SwiftNode] {
        let astNodes = parseSwiftFile(content)

        return astNodes.map { ast in
            SwiftNode(from: ast, allNodes: allNodes)
        }
    }
}

extension SwiftNode {
    /// 🎯 Доработанный convenience init
    convenience init(from ast: ASTNode, allNodes: [SwiftNode]) {
        let nodeDict = Dictionary(uniqueKeysWithValues: allNodes.map { ($0.name, $0) })

        switch ast {
        case let .class(name, inherits, members):
            let properties = members.compactMap { ast -> SwiftProperty? in
                if case let .property(name, type) = ast {
                    return SwiftProperty(name: name, type: type)
                }
                return nil
            }

            let functions = members.compactMap { ast -> SwiftFunction? in
                if case let .function(name, _, _) = ast {
                    return SwiftFunction(name: name)
                }
                return nil
            }

            // 💡 Строим корректные relationships:
            var relationships: [SwiftRelationship] = []

            for property in properties {
                let propertyType = property.name

                if let targetNode = nodeDict[propertyType] {
                    relationships.append(SwiftRelationship(
                        from: name,
                        to: targetNode.name,
                        type: .reference(strength: .strong)
                    ))
                }

                let conformingNodes = nodeDict.values.filter { $0.conformsTo.contains(propertyType) }
                for conformer in conformingNodes {
                    relationships.append(SwiftRelationship(
                        from: name,
                        to: conformer.name,
                        type: .reference(strength: .strong)
                    ))
                }
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
            self.init(
                name: name,
                type: .struct,
                conformsTo: [],
                properties: [],
                functions: [],
                relationships: []
            )

        default:
            self.init(name: "Anonymous", type: .unknown, conformsTo: [])
        }
    }
}
