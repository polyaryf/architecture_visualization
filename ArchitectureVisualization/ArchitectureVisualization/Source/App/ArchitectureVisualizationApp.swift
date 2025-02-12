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
    
    // MARK: - StateObject
    @StateObject private var fileLoader = FileLoader()
    
    // MARK: - States
    @State private var isDownloadButtonHidden = false
    @State private var shouldShowNotGrantedAccessToFilesAlert = false

    var body: some View {
        VStack {
            if !isDownloadButtonHidden {
                Button("Загрузить проект") {
                    fileLoader.requestPermissions { granted in
                        guard granted else {
                            shouldShowNotGrantedAccessToFilesAlert = true
                            return
                        }
                        isDownloadButtonHidden = true
                    }
                }
                .alert("Нет доступа к файлам", isPresented: $shouldShowNotGrantedAccessToFilesAlert) {
                    Button("Закрыть", role: .cancel) { }
                }
                .padding()
            }

            if let rootNode = fileLoader.rootNode {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        FileView(node: rootNode)
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
