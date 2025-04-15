//
//  ASTAnalyzer.swift
//  ArchitectureVisualizationTool
//
//  Created by Полина Рыфтина on 12.04.2025.
//

import Foundation
import SwiftSyntax
import SwiftParser

class ASTAnalyzer {
    
    private(set) var astTrees: [URL: SourceFileSyntax] = [:]
    private let nodeBuilder = ASTNodeBuilder(viewMode: .sourceAccurate)

    init(projectDirectory: URL) throws {
        try processDirectory(projectDirectory)
    }
    
    // MARK: Private

    private func processDirectory(_ directory: URL) throws {
        let fileManager = FileManager.default
        let resourceKeys: [URLResourceKey] = [.isDirectoryKey, .nameKey]
        guard let directoryEnumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: resourceKeys) else {
            return
        }

        for case let fileURL as URL in directoryEnumerator {
            let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))

            if resourceValues.isDirectory == true {
                continue // Папка — пропускаем
            }

            if fileURL.pathExtension == "swift" {
                try processSwiftFile(fileURL)
            }
        }
    }

    private func processSwiftFile(_ fileURL: URL) throws {
        let sourceCode = try String(contentsOf: fileURL, encoding: .utf8)

        var parser = Parser(sourceCode)
        let syntax = SourceFileSyntax.parse(from: &parser)

        astTrees[fileURL] = syntax
    }
}

// MARK: - ASTBuilder + Internal

extension ASTAnalyzer {
    
    var nodes: [ASTNode] {
        nodeBuilder.classes.values.map { $0 } + nodeBuilder.enums.values.map { $0 }
    }
    
    func astForFile(at url: URL) -> SourceFileSyntax? {
        return astTrees[url]
    }

    func forEachAST() -> DependencyGraph {
        for (_, ast) in astTrees {
            nodeBuilder.walk(ast)
        }
        
        print("Classes:")
//        nodeBuilder.classes.values.forEach { print($0) }

        print("Structs:")
//        nodeBuilder.structs.values.forEach { print($0) }

        print("Enums:")
//        nodeBuilder.enums.values.forEach { print($0) }
        
        let classes: [ClassNode] = nodeBuilder.classes.values.map { $0 }
        let structs: [StructNode] = nodeBuilder.structs.values.map { $0 }
        let enums: [EnumNode] = nodeBuilder.enums.values.map { $0 }

        let builder = DependencyGraphBuilder()
        let graph = builder.buildGraph(classNodes: classes, enumNodes: enums)

        print("Nodes:")
        for node in graph.nodes {
            print(node.name)
        }

        print("\nEdges:")
        for edge in graph.edges {
            print("\(edge.from.name) -> \(edge.to.name)")
        }
        return graph
    }
}
