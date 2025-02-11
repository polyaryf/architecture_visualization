//
//  FileView.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 10.02.2025.
//

import SwiftUI

struct FileView: View {
    let node: FileNode
    let level: Int
    @State private var isExpanded = false
    @State private var positions: [UUID: CGPoint] = [:]

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            HStack {
                if node.children != nil {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.gray)
                        .onTapGesture {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }
                }
                UMLNodeView(node: node)
                    .background(GeometryReader { geo in
                        Color.clear.onAppear {
                            DispatchQueue.main.async {
                                positions[node.id] = geo.frame(in: .global).origin
                            }
                        }
                    })
            }
            
            if isExpanded, let children = node.children {
                HStack(spacing: 40) {
                    ForEach(children) { child in
                        VStack {
                            FileView(node: child, level: level + 1)
                            if let parentPos = positions[node.id], let childPos = positions[child.id] {
                                UMLArrowView(start: parentPos, end: childPos)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
}
