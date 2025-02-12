//
//  FileLoader.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 10.02.2025.
//

import Foundation
import AppKit
import SwiftListTreeDataSource

class FileLoader: ObservableObject {
    @Published var rootNode: FileNode?

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

    private func createFileNode(from url: URL) -> FileNode {
        let fileManager = FileManager.default
        let fileType = determineFileType(for: url)

        var childrenNodes: [FileNode] = []

        if fileType == .folder, let contents = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
            childrenNodes = contents.map { createFileNode(from: $0) }
        }

        return FileNode(name: url.lastPathComponent, fileType: fileType, children: childrenNodes)
    }

    private func determineFileType(for url: URL) -> FileType {
        if url.hasDirectoryPath {
            return .folder
        }

        guard url.pathExtension == "swift",
              let content = try? String(contentsOf: url) else {
            return .folder
        }

        if content.contains("class ") {
            return .swiftClass
        } else if content.contains("struct ") {
            return .swiftStruct
        } else if content.contains("enum ") {
            return .swiftEnum
        } else if content.contains("protocol ") {
            return .swiftProtocol
        } else if content.contains("import SwiftUI") && content.contains("var body: some View") {
            return .swiftUIView
        }

        return .folder
    }
}
