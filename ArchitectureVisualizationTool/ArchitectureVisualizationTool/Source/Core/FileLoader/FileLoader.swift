//
//  FileLoader.swift
//  ArchitectureVisualizationTool
//
//  Created by Полина Рыфтина on 12.04.2025.
//

import Foundation
import AppKit

final class FileLoader: ObservableObject {
    
    private var analyzer: ASTAnalyzer?
    
    func requestPermissionsToOpenFileDirectory(completion: @escaping (Bool) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        
        panel.begin { response in
            if response == .OK, let selectedURL = panel.urls.first {
                do {
                    self.analyzer = try ASTAnalyzer(projectDirectory: selectedURL)
                } catch {
                    print("Ошибка: \(error)")
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func giveResult() -> DependencyGraph {
        analyzer?.forEachAST() ?? DependencyGraph(nodes: [], edges: [])
    }
    
    func giveNodes() -> [ASTNode] {
        analyzer?.nodes ?? []
    }
}
