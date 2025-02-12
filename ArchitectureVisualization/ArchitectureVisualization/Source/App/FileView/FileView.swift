//
//  FileView.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 10.02.2025.
//

import SwiftUI

struct FileView: View {
    let node: FileNode
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            HStack {
                if let children = node.children, !children.isEmpty {  // ✅ Проверка на nil и пустоту
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.gray)
                        .onTapGesture {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }
                }
                UMLNodeView(node: node)
            }

            if isExpanded, let children = node.children { // ✅ Разворачиваем `children` безопасно
                HStack(spacing: 40) { // Делаем горизонтальное расположение дочерних элементов
                    ForEach(children, id: \.id) { child in
                        VStack {
                            FileView(node: child)
                        }
                    }
                }
            }
        }
        .padding()
    }
}
