import Foundation

struct SwiftProperty: Codable, Hashable, Identifiable {
    var id = UUID()
    let name: String       // имя свойства
    let type: String       // тип свойства
    let modifier: PropertyReferenceModifier

    init(name: String, type: String, modifier: PropertyReferenceModifier = .strong) {
        self.name = name
        self.type = type
        self.modifier = modifier
    }
}

/// Модификаторы ссылок для свойств
enum PropertyReferenceModifier: String, Codable {
    case strong
    case weak
    case unowned
}
