//
//  UMLNodeView.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 10.02.2025.
//

import SwiftUI

import SwiftUI

struct UMLNodeView: View {
    let node: FileNode

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: node.fileType.iconName)
                    .foregroundColor(iconColor(for: node.fileType))

                Text(node.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor(for: node.fileType))
            .cornerRadius(8)
        }
        .padding(10)
        .shadow(radius: 3)
    }

    // MARK: - Цвета для разных типов файлов
    private func backgroundColor(for type: FileType) -> Color {
        switch type {
        case .folder: return Color.blue
        case .swiftClass: return Color.green
        case .swiftStruct: return Color.orange
        case .swiftEnum: return Color.purple
        case .swiftProtocol: return Color.red
        case .swiftUIView: return Color.teal
        }
    }

    private func iconColor(for type: FileType) -> Color {
        switch type {
        case .folder: return .yellow
        default: return .white
        }
    }
}
