import AppKit

final class FileLoader: ObservableObject {
    @Published var swiftNodes: [SwiftNode] = []
    @Published var pods: [PodNode] = []

    func loadFiles(from directoryURL: URL) {
        var swiftFiles: [URL] = []

        collectFiles(at: directoryURL, swiftFiles: &swiftFiles)

        var preliminaryNodes: [SwiftNode] = []

        for fileURL in swiftFiles {
            guard let content = try? String(contentsOf: fileURL) else { continue }
            let swiftNodes = SwiftNode.nodes(from: content, allNodes: [])
            preliminaryNodes.append(contentsOf: swiftNodes)
        }

        let finalNodes = preliminaryNodes.map { node in
            SwiftNode(
                name: node._name,
                type: node.type,
                conformsTo: node.conformsTo,
                properties: node.properties,
                functions: node.functions,
                relationships: buildRelationships(for: node, in: preliminaryNodes)
            )
        }

        DispatchQueue.main.async {
            self.swiftNodes = finalNodes
        }
    }

    private func collectFiles(at directoryURL: URL, swiftFiles: inout [URL]) {
        guard let enumerator = FileManager.default.enumerator(at: directoryURL, includingPropertiesForKeys: nil) else {
            return
        }

        for case let fileURL as URL in enumerator {
            if fileURL.lastPathComponent == "Pods" {
                enumerator.skipDescendants()
                continue
            }
            
            if fileURL.pathExtension == "swift" {
                swiftFiles.append(fileURL)
            }
        }
    }
}
