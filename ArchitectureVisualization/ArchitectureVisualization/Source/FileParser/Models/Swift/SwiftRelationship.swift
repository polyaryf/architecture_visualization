import Foundation

enum ReferenceStrength: String, Equatable, Hashable {
    case strong
    case weak
    case unowned
}

struct SwiftRelationship: Identifiable, Hashable {
    enum RelationshipType: Hashable {
        case aggregation  // Связь через переменную (value types)
        case composition  // Создается внутри класса
        case inheritance  // Наследование или реализация протокола
        case reference(strength: ReferenceStrength) // Ссылочный тип
    }

    let id = UUID()
    let from: String
    let to: String
    let type: RelationshipType
}

extension SwiftRelationship {
    static func from(ast: ASTNode, parent: String) -> [SwiftRelationship] {
        switch ast {
        case let .property(name, type):
            let lowerName = name.lowercased()
            let strength: ReferenceStrength

            if lowerName.contains("weak") {
                strength = .weak
            } else if lowerName.contains("unowned") {
                strength = .unowned
            } else {
                strength = .strong
            }

            return [SwiftRelationship(from: parent, to: type, type: .reference(strength: strength))]

        case let .function(_, _, parameters):
            return parameters.map {
                SwiftRelationship(from: parent, to: $0.1, type: .aggregation)
            }

        default:
            return []
        }
    }
}
