//
//  FileTypeStrategy.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 12.02.2025.
//

import Foundation

/// NodeType Strategy Protocol
protocol FileTypeStrategy {
    func determineType(for url: URL) -> NodeType?
}

class SwiftFileStrategy: FileTypeStrategy {

    private let excludedExtensions: Set<String> = [".pbxproj", ".xcodeproj"]

    func determineType(for url: URL) -> NodeType? {
        
        if excludedExtensions.contains(url.pathExtension.lowercased()) || isXcodeProjFolder(url) {
            return nil  // Возвращаем nil, чтобы исключить эту папку/файл
        }

        if url.hasDirectoryPath {
            return .folder
        }

        guard url.pathExtension == "swift", let content = try? String(contentsOf: url) else {
            return .folder
        }

        var swiftFileType: SwiftFileType = .unknown
        
        if content.contains("protocol ") {
            swiftFileType = .protocol
        } else if content.contains("struct ") {
            swiftFileType = .struct
        } else if content.contains("enum ") {
            swiftFileType = .enum
        } else if content.contains("class ") {
            swiftFileType = .class
        } else if content.contains("extension ") {
            swiftFileType = .extension
        }
        
        return .swiftFile(swiftFileType)
    }

    // Функция для проверки, является ли это папка с расширением .xcodeproj
    private func isXcodeProjFolder(_ url: URL) -> Bool {
        return url.lastPathComponent.lowercased().hasSuffix(".xcodeproj")
    }
}
