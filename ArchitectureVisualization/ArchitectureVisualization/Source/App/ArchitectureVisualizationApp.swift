import SwiftUI
import UniformTypeIdentifiers
import AppKit

@main
struct ArchitectureVisualizationApp: App {
    var body: some Scene {
        WindowGroup {
            MainContentView()
        }
    }
}

struct MainContentView: View {
    @StateObject private var fileLoader = FileLoader()
    
    @State private var isDownloadButtonHidden = false
    @State private var shouldShowNotGrantedAccessToFilesAlert = false

    var body: some View {
        VStack {
            if !isDownloadButtonHidden {
                Button("Загрузить проект") {
                    fileLoader.requestPermissions { granted in
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
            }

            if !fileLoader.swiftNodes.isEmpty {
                DiagramView(fileLoader: fileLoader)
            } else {
                Spacer()
                Text("Загрузите проект, чтобы увидеть архитектуру")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .padding()
    }
}
