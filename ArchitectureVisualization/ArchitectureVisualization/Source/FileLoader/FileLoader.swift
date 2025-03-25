import Foundation
import AppKit

class FileLoader: ObservableObject {
    
    // MARK: Singltone
    
    static let shared: FileLoader = FileLoader()
    
    @Published var swiftNodes: [SwiftNode] = []
    @Published var pods: [PodNode] = []

    private var fileTypeStrategy: FileTypeStrategy = SwiftFileStrategy()
    private var fileManager: FileManager = .default

    func requestPermissions(completion: @escaping (Bool) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.prompt = "Выбрать папку"
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false

        if openPanel.runModal() == .OK, let url = openPanel.url {
            completion(true)
            self.load(from: url)
        } else {
            completion(false)
        }
    }

    func load(from url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            let podsInfo = self.parsePodfile(from: url)
            let nodes = self.extractSwiftNodes(from: url)
            
            DispatchQueue.main.async {
                self.swiftNodes = nodes
                self.pods = podsInfo
            }
        }
    }
    
    private func extractSwiftNodes(from url: URL) -> [SwiftNode] {
        var nodes: [SwiftNode] = []
        
        if let projectfilesURLs = try? fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) {
            for url in projectfilesURLs {
                if url.hasDirectoryPath, url.lastPathComponent != "Pods" {
                    let childFiles = extractSwiftNodes(from: url)
                    for dataStruct in nodes {
                        nodes.append(dataStruct)
                    }
                } else {
                    guard url.pathExtension == "swift" else { continue }
                    nodes.append(contentsOf: fileTypeStrategy.determineAllSwiftNodsType(for: url))
                }
            }
        }
        
        return nodes
    }
    
    private func extractImports(from fileURL: URL) -> [String] {
        guard let content = try? String(contentsOf: fileURL) else { return [] }
        
        let regex = try! NSRegularExpression(pattern: #"import\s+(\w+)"#)
        let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
        
        var imports: [String] = []
        for match in matches {
            let moduleName = (content as NSString).substring(with: match.range(at: 1))
            imports.append(moduleName)
        }
        
        return Array(Set(imports))
    }
    
    private func shouldExclude(url: URL) -> Bool {
        return url.lastPathComponent.hasSuffix(".pbxproj") || url.lastPathComponent.hasSuffix(".xcodeproj")
    }
    
    
    private func parsePodfile(from url: URL) -> [PodNode] {
        let podfilePath = url.appendingPathComponent("Podfile")
        guard let content = try? String(contentsOf: podfilePath) else { return [] }
        
        var pods: [PodNode] = []
        let regex = try! NSRegularExpression(pattern: #"pod\s+['"]([^'"]+)['"],?\s*['"]?([^'"]+)?['"]?"#)
        let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
        
        for match in matches {
            let name = (content as NSString).substring(with: match.range(at: 1))
            let version = match.range(at: 2).location != NSNotFound ? (content as NSString).substring(with: match.range(at: 2)) : "latest"
            pods.append(PodNode(name: name, version: version))
        }
        
        return pods
    }
}
