//
//  FileHierarchyApp.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 10.02.2025.
//

import SwiftUI
import UniformTypeIdentifiers
import AppKit

@main
struct FileHierarchyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var fileLoader = FileLoader()
    
    var body: some View {
        VStack {
            Button("Загрузить проект") {
                fileLoader.requestPermissions { granted in
                    if !granted {
                        print("Доступ к файлам отклонен пользователем")
                    }
                }
            }
            .padding()
            
            if let rootNode = fileLoader.rootNode {
                ScrollView(.horizontal) {
                    HStack(alignment: .top) {
                        FileView(node: rootNode, level: 0)
                    }
                    .padding()
                }
            } else {
                Text("Выберите папку с проектом")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }
}
