import Foundation

enum ReferenceStrength: String, Equatable, Hashable {
    case strong
    case weak
    case unowned
}

struct SwiftRelationship: Identifiable, Hashable {
    enum RelationshipType: Hashable {
        case aggregation
        case composition
        case inheritance
        case reference(strength: ReferenceStrength)
    }

    let id = UUID()
    let from: String
    let to: String
    let type: RelationshipType
}

extension SwiftRelationship {
    static func from(ast: ASTNode, parent: String) -> [SwiftRelationship] {
        switch ast {
        case let .property(_, type):
            return [SwiftRelationship(from: parent, to: type, type: .reference(strength: .strong))]

        case let .function(_, parameters, _):
            return parameters.map { param in
                SwiftRelationship(from: parent, to: param.type, type: .aggregation)
            }

        default:
            return []
        }
    }
}
