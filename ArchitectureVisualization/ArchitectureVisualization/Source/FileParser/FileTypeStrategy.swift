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

        return SwiftNode.nodes(from: content)
    }

    private func isNotXcodeProjFolder(_ url: URL) -> Bool {
        !url.lastPathComponent.lowercased().hasSuffix(".xcodeproj")
    }

    private func isNotPodFile(_ url: URL) -> Bool {
        !url.lastPathComponent.contains("Podfile")
        || !url.lastPathComponent.contains("Gemfile")
    }
}
