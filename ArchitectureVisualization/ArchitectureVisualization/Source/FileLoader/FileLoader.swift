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
    @Published var rootNode: FileNode?

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

    private func createFileNode(from url: URL) -> FileNode? {
        // Если файл имеет исключаемое расширение или является папкой .pbxproj или .xcodeproj, то пропускаем его
        if shouldExclude(url: url) {
            return nil
        }

        let fileType: FileType?

        if url.hasDirectoryPath {
            fileType = .folder
        } else {
            fileType = fileTypeStrategy.determineType(for: url)
        }

        // Если файл или папка должен быть исключен, возвращаем nil
        if fileType == nil {
            return nil
        }

        var childrenNodes: [FileNode] = []

        // Если это папка, загружаем содержимое
        if fileType == .folder, let contents = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
            childrenNodes = contents.compactMap { createFileNode(from: $0) }
        }

        return FileNode(name: url.lastPathComponent, fileType: fileType!, children: childrenNodes)
    }

    // Проверка на файлы и папки, которые должны быть исключены
    private func shouldExclude(url: URL) -> Bool {
        return url.lastPathComponent.hasSuffix(".pbxproj") || url.lastPathComponent.hasSuffix(".xcodeproj")
    }
}
