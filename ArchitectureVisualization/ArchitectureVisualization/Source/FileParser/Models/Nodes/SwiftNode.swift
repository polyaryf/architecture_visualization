import Foundation

class SwiftNode: Equatable, Hashable, Identifiable {
    var id = UUID()
    var _name: String
    var type: SwiftNodeType
    var conformsTo: [String]
    var inheritsFrom: String?
    var properties: [SwiftProperty]
    var functions: [SwiftFunction]
    var relationships: [SwiftRelationship]

    init(
        name: String,
        type: SwiftNodeType,
        conformsTo: [String],
        properties: [SwiftProperty] = [],
        functions: [SwiftFunction] = [],
        relationships: [SwiftRelationship] = [],
        inheritsFrom: String? = nil
    ) {
        self._name = name
        self.type = type
        self.conformsTo = conformsTo
        self.inheritsFrom = inheritsFrom
        self.properties = properties
        self.functions = functions
        self.relationships = relationships
    }

    var name: String {
        (_name as NSString).deletingPathExtension
    }

    static func == (lhs: SwiftNode, rhs: SwiftNode) -> Bool {
        lhs.name == rhs.name &&
        lhs.type == rhs.type &&
        lhs.conformsTo == rhs.conformsTo &&
        lhs.properties == rhs.properties &&
        lhs.functions == rhs.functions &&
        lhs.relationships == rhs.relationships
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
        let preNodes = astNodes.map { SwiftNode(from: $0, allNodes: []) }
        return astNodes.map { SwiftNode(from: $0, allNodes: preNodes) }
    }
}


extension SwiftNode {
    convenience init(from ast: ASTNode, allNodes: [SwiftNode]) {
        switch ast {
        case let .class(name, inherits, members):
            let superclass = inherits.first(where: { inherited in
                allNodes.contains { $0.name == String(inherited) && $0.type == .class }
            })
            let protocols = inherits.filter { $0 != superclass }

            self.init(
                name: name,
                type: .class,
                conformsTo: protocols,
                properties: Self.extractProperties(from: members), functions: Self.extractFunctions(from: members), inheritsFrom: superclass
            )

        case let .struct(name, members):
            self.init(
                name: name,
                type: .struct,
                conformsTo: [],
                properties: Self.extractProperties(from: members), 
                functions: Self.extractFunctions(from: members),
                inheritsFrom: nil
            )

        default:
            self.init(
                name: "Unknown",
                type: .unknown,
                conformsTo: [],
                properties: [], functions: [], 
                inheritsFrom: nil
            )
        }
    }

    private static func extractProperties(from members: [ASTNode]) -> [SwiftProperty] {
        members.compactMap { node in
            if case let .property(rawName, type) = node {
                let lower = rawName.lowercased()
                let modifier: ReferenceModifier

                if lower.contains("weak") {
                    modifier = .weak
                } else if lower.contains("unowned") {
                    modifier = .unowned
                } else {
                    modifier = .strong
                }

                let cleanName = rawName
                    .replacingOccurrences(of: "weak", with: "")
                    .replacingOccurrences(of: "unowned", with: "")
                    .trimmingCharacters(in: .whitespaces)

                return SwiftProperty(name: cleanName, type: type, modifier: modifier)
            }
            return nil
        }
    }

    private static func extractFunctions(from members: [ASTNode]) -> [SwiftFunction] {
        members.compactMap { node in
            if case let .function(name, _, _) = node {
                return SwiftFunction(name: name)
            }
            return nil
        }
    }
}
