//
//  ASTNode.swift
//  ArchitectureVisualizationTool
//
//  Created by Полина Рыфтина on 12.04.2025.
//

import Foundation

protocol ASTNode {
    var name: String { get }
    var protocols: [String] { get set }
    var properties: [PropertyNode] { get set }
    var functions: [String] { get set }
    var kind: TypeKind { get set }
}

enum TypeKind {
    case `class`
    case `struct`
    case `enum`
    case `extension`(originalType: String)
    
    var rawValue: String {
        switch self {
        case .class: "class"
        case .struct: "struct"
        case .enum: "enum"
        case .extension(let originalType): "extension \(originalType)" 
        }
    }
}

struct PropertyNode: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let type: String
    let ownership: Ownership
}

enum Ownership {
    case strong
    case weak
    case unowned
}

struct ClassNode: ASTNode {
    let name: String
    var protocols: [String] = []
    var properties: [PropertyNode] = []
    var functions: [String] = []
    var kind: TypeKind = .class
}

struct StructNode: ASTNode {
    let name: String
    var protocols: [String] = []
    var properties: [PropertyNode] = []
    var functions: [String] = []
    var kind: TypeKind = .struct
}

struct EnumNode: ASTNode {
    let name: String
    var cases: [String] = []
    var protocols: [String] = []
    var properties: [PropertyNode] = []
    var functions: [String] = []
    var kind: TypeKind = .enum
}

struct PodNode {
    let name: String
    let version: String
}
