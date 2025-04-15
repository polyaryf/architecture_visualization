//
//  NodeView.swift
//  ArchitectureVisualizationTool
//
//  Created by Полина Рыфтина on 12.04.2025.
//

import SwiftUI

struct NodeView: View {
    let node: ASTNode

    private var protocols: [String] { node.protocols }
    private var functions: [String] { node.functions }
    private var properties: [PropertyNode] { node.properties }

    @State private var showProtocols = false
    @State private var showFunctions = false
    @State private var showProperties = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(node.name)
                .font(.headline)
                .multilineTextAlignment(.leading)

            DisclosureGroup("Protocols", isExpanded: $showProtocols) {
                ForEach(protocols, id: \..self) { proto in
                    Text(proto)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            DisclosureGroup("Functions", isExpanded: $showFunctions) {
                ForEach(functions, id: \..self) { function in
                    Text(function)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            DisclosureGroup("Properties", isExpanded: $showProperties) {
                ForEach(properties, id: \..self) { property in
                    Text(property.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(width: 180, alignment: .leading)
        .background(Color.blue.opacity(0.2))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue, lineWidth: 2)
        )
    }
}

struct EnhancedNodeView: View {
    let node: ASTNode

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: iconName(for: node.kind))
                    .foregroundColor(iconColor(for: node.kind))
                Text("\(node.kind.rawValue.capitalized): \(node.name)")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.gray)
            }

            Divider()

            if !node.properties.isEmpty {
                ExpandableSection(title: "Properties", data: node.properties) { property in
                    Label(property.name, systemImage: "p.circle")
                        .foregroundColor(.gray)
                }
            }

            if !node.functions.isEmpty {
                ExpandableSection(title: "Functions",
                                  data: node.functions.map {
                    IdentifiableString(id: $0, value: $0)
                }) { function in
                    Label(function.value, systemImage: "f.cursive")
                        .foregroundColor(.gray)
                }
            }

            if !node.protocols.isEmpty {
                ExpandableSection(title: "Conforms To", data: node.protocols.map { IdentifiableString(id: $0, value: $0) }) { protocolName in
                    Label(protocolName.value, systemImage: "checkmark.shield")
                        .foregroundColor(.blue)
                }
            }


        }
        .padding()
        .frame(width: 250, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    private func iconName(for type: TypeKind) -> String {
        switch type {
        case .class: return "cube.box"
        case .struct: return "puzzlepiece.extension"
        case .enum: return "square.stack.3d.forward.dottedline"
        default: return "questionmark"
        }
    }

    private func iconColor(for type: TypeKind) -> Color {
        switch type {
        case .class: return .orange
        case .struct: return .green
        case .enum: return .purple
        default: return .gray
        }
    }
}

struct IdentifiableString: Identifiable {
    let id: String
    let value: String
}

