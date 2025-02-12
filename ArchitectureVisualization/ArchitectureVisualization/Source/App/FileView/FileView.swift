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
                // Вместо стрелочки теперь будет просто иконка для папки
                if let children = node.children, !children.isEmpty {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.gray)
                }
                
                // Нажатие на саму вьюшку с папкой для разворачивания
                UMLNodeView(node: node)
                    .onTapGesture {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
            }

            // Показ дочерних элементов, если они есть и если развернуто
            if isExpanded, let children = node.children {
                HStack(spacing: 40) { // Горизонтальное расположение дочерних элементов
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
