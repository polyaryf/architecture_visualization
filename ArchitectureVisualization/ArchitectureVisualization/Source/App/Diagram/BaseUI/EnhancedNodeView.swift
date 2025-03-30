//
//  EnhancedNodeView.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 30.03.2025.
//

import SwiftUI

struct EnhancedNodeView: View {
    let node: SwiftNode

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: iconName(for: node.type))
                    .foregroundColor(iconColor(for: node.type))
                Text("\(node.type.rawValue.capitalized): \(node.name)")
                    .font(.title3)
                    .bold()
            }

            Divider()

            if !node.properties.isEmpty {
                ExpandableSection(title: "Properties") {
                    ForEach(node.properties, id: \ .id) { property in
                        Label(property.name, systemImage: "p.circle")
                            .foregroundColor(.gray)
                    }
                }
            }

            if !node.functions.isEmpty {
                ExpandableSection(title: "Functions") {
                    ForEach(node.functions, id: \ .id) { function in
                        Label(function.name, systemImage: "f.cursive")
                            .foregroundColor(.gray)
                    }
                }
            }

            if !node.conformsTo.isEmpty {
                ExpandableSection(title: "Conforms To") {
                    ForEach(node.conformsTo, id: \ .self) { protocolName in
                        Label(protocolName, systemImage: "checkmark.shield")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    private func iconName(for type: SwiftNodeType) -> String {
        switch type {
        case .class: return "cube.box"
        case .struct: return "puzzlepiece.extension"
        case .enum: return "square.stack.3d.forward.dottedline"
        default: return "questionmark"
        }
    }

    private func iconColor(for type: SwiftNodeType) -> Color {
        switch type {
        case .class: return .orange
        case .struct: return .green
        case .enum: return .purple
        default: return .gray
        }
    }
}
