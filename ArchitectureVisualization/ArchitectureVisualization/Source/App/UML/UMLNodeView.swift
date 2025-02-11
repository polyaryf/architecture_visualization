//
//  UMLNodeView.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 10.02.2025.
//

import SwiftUI

struct UMLNodeView: View {
    let node: FileNode

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: node.isFolder ? "folder.fill" : "doc.fill")
                    .foregroundColor(node.isFolder ? .blue : .gray)

                Text(node.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(node.isFolder ? Color.blue : Color.gray)
            .cornerRadius(8)
        }
        .padding(10)
        .shadow(radius: 3)
    }
}
