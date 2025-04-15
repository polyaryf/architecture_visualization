import Foundation

struct FileTypeStrategy {
    /// Считывает все SwiftNodes из массива файлов проекта без построения связей
    static func extractPreliminaryNodes(from projectfilesURLs: [URL]) -> [SwiftNode] {
        var preliminaryNodes: [SwiftNode] = []

        for fileURL in projectfilesURLs {
            if fileURL.hasDirectoryPath, fileURL.lastPathComponent != "Pods" {
                preliminaryNodes.append(contentsOf: extractSwiftNodes(from: fileURL))
            } else if fileURL.pathExtension == "swift" {
                guard let content = try? String(contentsOf: fileURL) else { continue }
                let swiftNodes = SwiftNode.nodes(from: content, allNodes: []) // allNodes пустой на этом этапе
                preliminaryNodes.append(contentsOf: swiftNodes)
            }
        }

        return preliminaryNodes
    }

    /// Рекурсивно обходит директорию и собирает Swift файлы
    private static func extractSwiftNodes(from directoryURL: URL) -> [SwiftNode] {
        var swiftNodes: [SwiftNode] = []

        guard let enumerator = FileManager.default.enumerator(at: directoryURL, includingPropertiesForKeys: nil) else {
            return []
        }

        for case let fileURL as URL in enumerator {
            if fileURL.lastPathComponent == "Pods" {
                enumerator.skipDescendants()
                continue
            }

            if fileURL.pathExtension == "swift" {
                guard let content = try? String(contentsOf: fileURL) else { continue }
                let nodes = SwiftNode.nodes(from: content, allNodes: []) // также пустой массив
                swiftNodes.append(contentsOf: nodes)
            }
        }

        return swiftNodes
    }
}
