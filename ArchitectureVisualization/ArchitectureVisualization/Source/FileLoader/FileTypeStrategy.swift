import Foundation

protocol FileTypeStrategy {
    func determineAllSwiftNodsType(for url: URL) -> [SwiftNode]
}

class SwiftFileStrategy: FileTypeStrategy {
    
    private let excludedExtensions: Set<String> = [
        ".pbxproj", ".xcodeproj", ".lock", ".xcworkspace",
    ]
    
    private func precheck(for url: URL) -> Bool {
        !excludedExtensions.contains(url.pathExtension.lowercased())
        || isNotXcodeProjFolder(url)
        || isNotPodFile(url)
    }
    
    func determineAllSwiftNodsType(for url: URL) -> [SwiftNode] {
        guard precheck(for: url),
              !url.hasDirectoryPath,
              url.pathExtension == "swift",
              let content = try? String(contentsOf: url)
        else { return [] }
        
        var dataStructures: [SwiftNode] = []
        parseFileCode(content, into: &dataStructures)
        return dataStructures
    }
    
    private func parseFileCode(_ code: String, into model: inout [SwiftNode]) {
        let lines = code.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
        var currentDataStruct: SwiftNode?
        
        for line in lines {
            if line.hasPrefix("protocol ") {
                let (name, conformsTo) = extractNameAndConformsTo(from: line)
//                model.append(
//                    SwiftNode(
//                        name: name,
//                        type: .protocol,
//                        conformsTo: conformsTo
//                    )
//                )
            } else if line.hasPrefix("class ") {
                let (name, conformsTo) = extractNameAndConformsTo(from: line)
                var dataStruct = SwiftNode(
                    name: name,
                    type: .class,
                    conformsTo: conformsTo
                )
                currentDataStruct = dataStruct
                for protocolName in conformsTo {
                    dataStruct.relationships.append(
                        SwiftRelationship(
                            from: name,
                            to: protocolName,
                            type: .inheritance
                        )
                    )
                }
                model.append(dataStruct)
            } else if let currentDataStruct = currentDataStruct, line.contains("let ") {
                let property = extractProperty(from: line)
                currentDataStruct.relationships.append(
                    SwiftRelationship(
                        from: currentDataStruct.name,
                        to: property.name,
                        type: .aggregation
                    )
                )
            }
        }
    }
    
    private func extractName(from line: String, prefix: String) -> String {
        if let range = line.range(of: prefix) {
            let name = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
            return name.components(separatedBy: " ").first ?? "no name"
        }
        return "no name"
    }
    
    private func isNotXcodeProjFolder(_ url: URL) -> Bool {
        !url.lastPathComponent.lowercased().hasSuffix(".xcodeproj")
    }
    
    private func isNotPodFile(_ url: URL) -> Bool {
        !url.lastPathComponent.contains("Podfile")
        || !url.lastPathComponent.contains("Gemfile")
    }
    
    private func extractNameAndConformsTo(from line: String) -> (String, [String]) {
        let components = line.replacingOccurrences(of: "class", with: "").split(separator: ":").map { $0.trimmingCharacters(in: .whitespaces) }
        let name = components.first ?? ""
        let conformsTo = components.count > 1 ? components[1].split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } : []
        return (name, conformsTo)
    }
    
    private func extractProperty(from line: String) -> SwiftProperty {
        let parts = line.split(separator: ":").map { $0.trimmingCharacters(in: .whitespaces) }
        let name = parts.first?.components(separatedBy: " ").last ?? ""
//        let type = parts.count > 1 ? parts[1] : ""
        return SwiftProperty(name: name)
    }
}
