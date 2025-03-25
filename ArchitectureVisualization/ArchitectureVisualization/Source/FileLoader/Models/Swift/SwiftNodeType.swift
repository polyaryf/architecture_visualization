import Foundation

enum SwiftNodeType: String, Equatable, Hashable {
    case `struct`
    case `enum`
    case `class`
    case `unknown`
}

struct SwiftRelationship: Identifiable, Hashable {
    
    enum RelationshipType {
        case aggregation  // Связь через переменную
        case composition  // Создается внутри класса
        case inheritance  // Наследование или реализация протокола
    }
    
    let id = UUID()
    let from: String
    let to: String
    let type: RelationshipType
}
