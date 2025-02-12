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

    private let excludedExtensions: Set<String> = [
        ".pbxproj", ".xcodeproj", ".lock", ".xcworkspace",
    ]

    func determineType(for url: URL) -> NodeType? {
        
        if excludedExtensions.contains(url.pathExtension.lowercased()) 
            || isXcodeProjFolder(url)
            || isPodFile(url)
        {
            return nil
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

    private func isXcodeProjFolder(_ url: URL) -> Bool {
        url.lastPathComponent.lowercased().hasSuffix(".xcodeproj")
    }
    
    private func isPodFile(_ url: URL) -> Bool {
        url.lastPathComponent.contains("Podfile")
        || url.lastPathComponent.contains("Gemfile")
    }
}
