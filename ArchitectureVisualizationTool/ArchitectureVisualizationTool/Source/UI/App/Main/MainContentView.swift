//
//  ContentView.swift
//  ArchitectureVisualizationTool
//
//  Created by Полина Рыфтина on 12.04.2025.
//

import SwiftUI

struct MainContentView: View {

    @StateObject var fileLoader = FileLoader()
    
    // MARK: States
    
    @State private var isDownloadButtonHidden = false
    @State private var shouldShowNotGrantedAccessToFilesAlert = false

    var body: some View {
        if !isDownloadButtonHidden {
            Button("Загрузить проект") {
                fileLoader.requestPermissionsToOpenFileDirectory { granted in
                    if granted {
                        isDownloadButtonHidden = true
                    } else {
                        shouldShowNotGrantedAccessToFilesAlert = true
                    }
                }
            }
            .alert("Нет доступа к файлам", isPresented: $shouldShowNotGrantedAccessToFilesAlert) {
                Button("Закрыть", role: .cancel) {}
            }
            .padding()
        } else {
            GraphView(
                graph: fileLoader.giveResult(),
                allNodes: fileLoader.giveNodes()
            )
        }
    }
}

#Preview {
    MainContentView()
}
