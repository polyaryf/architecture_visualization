//
//  FileTypeStrategy.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 12.02.2025.
//

import Foundation

/// FileType Strategy Protocol
protocol FileTypeStrategy {
    func determineType(for url: URL) -> FileType?
}

class SwiftFileStrategy: FileTypeStrategy {
    // Множество для хранения фильтров, которые мы хотим исключить
    private let excludedExtensions: Set<String> = [".pbxproj", ".xcodeproj"]

    func determineType(for url: URL) -> FileType? {
        // Проверка на расширение, которое нужно исключить
        if excludedExtensions.contains(url.pathExtension.lowercased()) || isXcodeProjFolder(url) {
            return nil  // Возвращаем nil, чтобы исключить эту папку/файл
        }

        if url.hasDirectoryPath {
            return .folder
        }

        guard url.pathExtension == "swift", let content = try? String(contentsOf: url) else {
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

    // Функция для проверки, является ли это папка с расширением .xcodeproj
    private func isXcodeProjFolder(_ url: URL) -> Bool {
        return url.lastPathComponent.lowercased().hasSuffix(".xcodeproj")
    }
}
