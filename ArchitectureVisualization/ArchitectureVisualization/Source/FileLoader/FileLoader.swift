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

    private var fileTypeStrategy: FileTypeStrategy
    private var fileManager: FileManager

    init(fileTypeStrategy: FileTypeStrategy = SwiftFileStrategy(), fileManager: FileManager = .default) {
        self.fileTypeStrategy = fileTypeStrategy
        self.fileManager = fileManager
    }

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
            let rootNode = self.createFileNode(from: url)
            DispatchQueue.main.async {
                self.rootNode = rootNode
            }
        }
    }

    private func createFileNode(from url: URL) -> Node? {
        // Если файл имеет исключаемое расширение или является папкой .pbxproj или .xcodeproj, то пропускаем его
        if shouldExclude(url: url) {
            return nil
        }

        let nodeType: NodeType?
        var swiftFileType: SwiftFileType? = nil

        if url.hasDirectoryPath {
            nodeType = .folder
        } else {
            nodeType = fileTypeStrategy.determineType(for: url)
        }

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

    // Проверка на файлы и папки, которые должны быть исключены
    private func shouldExclude(url: URL) -> Bool {
        return url.lastPathComponent.hasSuffix(".pbxproj") || url.lastPathComponent.hasSuffix(".xcodeproj")
    }
}
