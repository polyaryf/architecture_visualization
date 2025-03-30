import Foundation

struct SwiftFunction: Equatable, Hashable {
    let id = UUID()
    let name: String
    let isAsync: Bool = false
}
