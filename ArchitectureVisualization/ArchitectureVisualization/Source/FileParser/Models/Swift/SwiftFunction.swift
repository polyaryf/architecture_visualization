import Foundation

struct SwiftFunction: Equatable, Hashable, Identifiable {
    let id: UUID
    let name: String
    let parameters: [(name: String, type: String)]
    let returnType: String
    let isAsync: Bool

    init(
        id: UUID = UUID(),
        name: String,
        parameters: [(name: String, type: String)] = [],
        returnType: String = "Void",
        isAsync: Bool = false
    ) {
        self.id = id
        self.name = name
        self.parameters = parameters
        self.returnType = returnType
        self.isAsync = isAsync
    }

    static func == (lhs: SwiftFunction, rhs: SwiftFunction) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.parameters.map { "\($0.name):\($0.type)" } == rhs.parameters.map { "\($0.name):\($0.type)" } &&
            lhs.returnType == rhs.returnType &&
            lhs.isAsync == rhs.isAsync
    }


    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(parameters.map { "\($0.name):\($0.type)" }.joined(separator: ","))
        hasher.combine(returnType)
        hasher.combine(isAsync)
    }
}
