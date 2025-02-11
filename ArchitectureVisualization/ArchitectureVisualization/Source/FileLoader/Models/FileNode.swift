//
//  FileType.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 10.02.2025.
//

import Foundation

enum FileType {
    case folder
    case swiftClass
    case swiftStruct
    case swiftEnum
    case swiftProtocol
    case swiftUIView
}

struct FileNode: Identifiable {
    let id = UUID()
    let name: String
    let isFolder: Bool
    let url: URL
    let children: [FileNode]?
}
