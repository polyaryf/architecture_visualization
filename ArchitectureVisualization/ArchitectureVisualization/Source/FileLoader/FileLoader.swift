//
//  FileLoader.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 10.02.2025.
//


import Foundation
import AppKit

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
        var children: [FileNode] = []

        if let contents = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
            for content in contents {
                children.append(createFileNode(from: content))
            }
        }

        let fileType = determineFileType(for: url)
        
        return FileNode(
            name: url.lastPathComponent,
            isFolder: fileType == .folder ? true : false,
            url: url,
            children: children.isEmpty ? nil : children.sorted(by: { $0.name < $1.name })
        )
    }

    private func determineFileType(for url: URL) -> FileType {
        if url.hasDirectoryPath {
            return .folder
        }

        guard url.pathExtension == "swift",
              let content = try? String(contentsOf: url) else {
            return .folder // Если файл не .swift, обрабатываем как папку (или добавить другой тип)
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

    private func extractAttributes(from url: URL) -> [String] {
        guard url.pathExtension == "swift",
              let content = try? String(contentsOf: url) else {
            return []
        }

        let regex = try? NSRegularExpression(pattern: "(var|let)\\s+(\\w+)", options: [])
        let matches = regex?.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count)) ?? []

        return matches.compactMap { match in
            if let range = Range(match.range(at: 2), in: content) {
                return String(content[range])
            }
            return nil
        }
    }

    private func extractMethods(from url: URL) -> [String] {
        guard url.pathExtension == "swift",
              let content = try? String(contentsOf: url) else {
            return []
        }

        let regex = try? NSRegularExpression(pattern: "func\\s+(\\w+)", options: [])
        let matches = regex?.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count)) ?? []

        return matches.compactMap { match in
            if let range = Range(match.range(at: 1), in: content) {
                return String(content[range]) + "()"
            }
            return nil
        }
    }
}
