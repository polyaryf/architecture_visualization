//
//  UMLDiagramView.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 10.02.2025.
//

import SwiftUI

struct DiagramView: View {
    @ObservedObject var fileLoader: FileLoader

    var body: some View {
        HStack(alignment: .top, spacing: 50) { // ✅ Подключенные Pod'ы слева
            if !fileLoader.pods.isEmpty {
                VStack(alignment: .leading) {
                    Text("Pods")
                        .font(.title2)
                        .bold()
                    ForEach(fileLoader.pods) { pod in
                        PodView(pod: pod)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }

            if let rootNode = fileLoader.rootNode {
                FileView(node: rootNode)
            }
        }
        .padding()
    }
}
