import Foundation

enum ReferenceModifier: String, Codable {
    case strong, weak, unowned
}

struct SwiftProperty: Codable, Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let type: String
    let modifier: ReferenceModifier
}
