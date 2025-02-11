//
//  UMLDiagramView.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 10.02.2025.
//

import SwiftUI

struct UMLDiagramView: View {
    let rootNode: FileNode?
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                ScrollView(.vertical) {
                    VStack {
                        if let rootNode = rootNode {
                            UMLNodeView(node: rootNode)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offset = value.translation
                            }
                    )
                }
            }
        }
        .overlay(UMLControlPanel(scale: $scale, offset: $offset), alignment: .topTrailing)
    }
}
