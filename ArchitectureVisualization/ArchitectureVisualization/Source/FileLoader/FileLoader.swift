//
//  FileLoader.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 10.02.2025.
//

import Foundation
import AppKit
import SwiftListTreeDataSource


// MARK: - FileLoader

class FileLoader: ObservableObject {
    @Published var rootNode: Node?
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
            let rootNode = self.createFileNode(from: url)
            
            DispatchQueue.main.async {
                self.rootNode = rootNode
                self.pods = podsInfo
            }
        }
    }

    private func createFileNode(from url: URL) -> Node? {
        guard !shouldExclude(url: url) else { return nil }
        guard url.lastPathComponent != "Pods" else { return nil }
    
        let nodeType: NodeType?
        var swiftFileType: SwiftFileType? = nil

        url.hasDirectoryPath ? (nodeType = .folder) : (nodeType = fileTypeStrategy.determineType(for: url))
        
        // Если файл или папка должен быть исключен, возвращаем nil
        guard let nodeType else { return nil }

        var childrenNodes: [Node] = []

        // Если это папка, загружаем содержимое
        if nodeType == .folder, let contents = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
            childrenNodes = contents.compactMap { createFileNode(from: $0) }
        }
        if case NodeType.swiftFile(let type) = nodeType {
            swiftFileType = type
        }

        return Node(
            name: url.lastPathComponent,
            url: url,
            nodeType: nodeType,
            swiftFileType: swiftFileType,
            children: childrenNodes
        )
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
