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
    
    // MARK: - StateObject
    
    @StateObject private var fileLoader = FileLoader.shared
    
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
            
            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {
                HStack(alignment: .top) {
                    DiagramView(fileLoader: fileLoader)
                }
                .padding()
            }
        }
    }
}
