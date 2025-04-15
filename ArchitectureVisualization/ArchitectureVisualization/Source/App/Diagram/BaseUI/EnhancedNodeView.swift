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
                ExpandableSection(title: "Functions", data: node.functions) { function in
                    Label(function.name, systemImage: "f.cursive")
                        .foregroundColor(.gray)
                }
            }

            if !node.conformsTo.isEmpty {
                ExpandableSection(title: "Conforms To", data: node.conformsTo.map { IdentifiableString(id: $0, value: $0) }) { protocolName in
                    Label(protocolName.value, systemImage: "checkmark.shield")
                        .foregroundColor(.blue)
                }
            }


        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
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

struct IdentifiableString: Identifiable {
    let id: String
    let value: String
}
