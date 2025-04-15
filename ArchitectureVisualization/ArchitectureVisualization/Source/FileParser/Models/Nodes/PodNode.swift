import Foundation

struct PodNode: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let version: String

    static func from(content: String) -> PodNode? {
        // Простая логика парсинга Podfile.lock
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("- ") {
                let components = trimmed.dropFirst(2).components(separatedBy: " ")
                if let name = components.first,
                   let versionPart = components.last?.trimmingCharacters(in: CharacterSet(charactersIn: "()")) {
                    return PodNode(name: name, version: versionPart)
                }
            }
        }
        return nil
    }
}
