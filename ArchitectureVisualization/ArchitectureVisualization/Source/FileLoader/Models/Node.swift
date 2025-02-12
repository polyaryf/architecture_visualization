//
//  NodeType.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 10.02.2025.
//

import Foundation
import SwiftListTreeDataSource

// MARK: - NodeType

enum NodeType: Equatable {
    case folder
    case swiftFile(SwiftFileType)
    case pod(version: String)
    
    var name: String {
        switch self {
        case .folder:
            "folder"
        case .swiftFile(let swiftFileType):
            switch swiftFileType {
            case .protocol:
                "protocol"
            case .struct:
                "struct"
            case .enum:
                "enum"
            case .class:
                "class"
            case .extension:
                "extension"
            case .unknown:
                "unknown"
            }
        case .pod(version: let version):
            "pod version: \(version)"
        }
    }
}

enum SwiftFileType: Equatable {
    case `protocol`, `struct`, `enum`, `class`, `extension`, `unknown`
}

class Node: Identifiable {
    let id = UUID()
    
    var url: URL
    var nodeType: NodeType
    var swiftFileType: SwiftFileType?
    var children: [Node]?
    
    private var _name: String

    init(
        name: String,
        url: URL,
        nodeType: NodeType,
        swiftFileType: SwiftFileType? = nil,
        children: [Node]? = nil
    ) {
        self._name = name
        self.url = url
        self.nodeType = nodeType
        self.swiftFileType = swiftFileType
        self.children = children
    }
    
    var isFolder: Bool {
        nodeType == .folder ? true : false
    }
    
    var name: String {
        (_name as NSString).deletingPathExtension
    }
}
