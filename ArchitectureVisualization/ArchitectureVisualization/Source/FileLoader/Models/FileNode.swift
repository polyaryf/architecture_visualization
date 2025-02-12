//
//  FileType.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 10.02.2025.
//

import Foundation
import SwiftListTreeDataSource

import Foundation

enum FileType {
    case folder
    case swiftClass
    case swiftStruct
    case swiftEnum
    case swiftProtocol
    case swiftUIView

    var iconName: String {
        switch self {
        case .folder: return "folder.fill"
        case .swiftClass: return "doc.text"
        case .swiftStruct: return "doc.text"
        case .swiftEnum: return "doc.text"
        case .swiftProtocol: return "doc.text"
        case .swiftUIView: return "square.stack.3d.up"
        }
    }
}

class FileNode: Identifiable {
    let id = UUID()
    let name: String
    let fileType: FileType
    let children: [FileNode]?

    init(name: String, fileType: FileType, children: [FileNode]? = nil) {
        self.name = name
        self.fileType = fileType
        self.children = children
    }

    var isFolder: Bool {
        return fileType == .folder
    }
}
