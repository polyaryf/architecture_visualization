import Foundation

class SwiftNode: Equatable, Hashable, Identifiable {
    let id = UUID()
    let _name: String
    let type: SwiftNodeType
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
}
