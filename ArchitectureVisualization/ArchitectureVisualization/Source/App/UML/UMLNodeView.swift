//
//  UMLNodeView.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 10.02.2025.
//

import SwiftUI

import SwiftUI

struct UMLNodeView: View {
    let node: Node

    var body: some View {
        VStack {
            Text(getFileNameWithoutExtension(node.name)) // ✅ Убираем расширение
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .frame(minWidth: 150, maxWidth: .infinity)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(1)
            if case let NodeType.pod(version: podVersion) = node.nodeType {
                Text("v\(podVersion)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 10)
            } else if let swiftFileType = node.swiftFileType {
                Text(swiftFileTypeDescription(swiftFileType))
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
            }
        }
        .padding(12)
        .frame(minWidth: 150, maxWidth: .infinity, minHeight: 60)
        .background(getBackgroundColor(for: node))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(getBorderColor(for: node), lineWidth: 2)
        )
        .shadow(radius: 5)
    }

    private func getFileNameWithoutExtension(_ fileName: String) -> String {
        return (fileName as NSString).deletingPathExtension
    }

    /// **Подключенные Pod'ы выделяем синим цветом**
    private func getBackgroundColor(for node: Node) -> Color {
        if case let NodeType.pod(version: version) = node.nodeType {
            return Color.blue.opacity(0.3)
        }
        guard case NodeType.swiftFile(let type) = node.nodeType else {
            return Color.gray.opacity(0.2)
        }
        switch type {
        case .protocol:
            return Color.blue.opacity(0.3)
        case .struct:
            return Color.green.opacity(0.3)
        case .enum:
            return Color.purple.opacity(0.3)
        case .class:
            return Color.orange.opacity(0.3)
        case .extension:
            return Color.yellow.opacity(0.3)
        default:
            return Color.clear
        }
    }

    /// **Обводка Pod'ов делаем синей**
    private func getBorderColor(for node: Node) -> Color {
        if case let NodeType.pod(version: version) = node.nodeType {
            return Color.blue
        }
        guard let swiftFileType = node.swiftFileType else {
            return Color.gray
        }
        switch swiftFileType {
        case .protocol:
            return Color.blue
        case .struct:
            return Color.green
        case .enum:
            return Color.purple
        case .class:
            return Color.orange
        case .extension:
            return Color.yellow
        default:
            return Color.clear
        }
    }
    
    private func swiftFileTypeDescription(_ type: SwiftFileType) -> String {
        switch type {
        case .protocol: return "Protocol"
        case .struct: return "Struct"
        case .enum: return "Enum"
        case .class: return "Class"
        case .extension: return "Extension"
        default: return "Unknown"
        }
    }
}
