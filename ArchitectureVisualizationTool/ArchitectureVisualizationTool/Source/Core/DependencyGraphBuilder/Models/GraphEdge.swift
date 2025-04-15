//
//  GraphEdge.swift
//  ArchitectureVisualizationTool
//
//  Created by Полина Рыфтина on 12.04.2025.
//

import Foundation

struct GraphEdge: Hashable {
    let from: GraphNode
    let to: GraphNode
    let ownership: Ownership
}
