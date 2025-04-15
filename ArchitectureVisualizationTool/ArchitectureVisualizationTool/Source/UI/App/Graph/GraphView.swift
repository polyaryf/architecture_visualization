//
//  GraphView.swift
//  ArchitectureVisualizationTool
//
//  Created by Полина Рыфтина on 12.04.2025.
//

import SwiftUI

struct GraphView: View {
    
    let graph: DependencyGraph
    let allNodes: [ASTNode]

    @State private var offset: CGSize = .zero
    @State private var lastDragPosition: CGSize = .zero
    @State private var scale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                ZStack {
                    let positions = calculateNodePositions(in: geometry.size)

                    ZStack {
                        // Edges (arrows)
                        EdgesView(
                            graph: graph,
                            nodePositions: positions,
                            scale: 1.0, // No manual scaling here
                            offset: .zero, // Offset will apply globally
                            gridSpacing: 300
                        )

                        // Nodes
                        ForEach(Array(allNodes), id: \..name) { node in
                            if let position = positions[node.name] {
                                EnhancedNodeView(node: node)
                                    .position(x: position.x, y: position.y)
                            }
                        }
                    }
                    .transformEffect(
                        CGAffineTransform(translationX: offset.width, y: offset.height)
                            .scaledBy(x: scale, y: scale)
                    )
                }
                .frame(width: geometry.size.width * 2, height: geometry.size.height * 2)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastDragPosition.width + value.translation.width,
                                height: lastDragPosition.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastDragPosition = offset
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = value
                        }
                )
            }
        }
    }

    private func calculateNodePositions(in size: CGSize) -> [String: CGPoint] {
        let nodes = Array(graph.nodes)
        let spacing: CGFloat = 400
        let itemWidth: CGFloat = 250
        let itemHeight: CGFloat = 550
        let totalColumns = Int(ceil(sqrt(Double(nodes.count))))

        var positions: [String: CGPoint] = [:]

        for (index, node) in nodes.enumerated() {
            let row = index / totalColumns
            let column = index % totalColumns

            let x = CGFloat(column) * spacing + itemWidth
            let y = CGFloat(row) * spacing + itemHeight

            positions[node.name] = CGPoint(x: x, y: y)
        }

        return positions
    }
}
