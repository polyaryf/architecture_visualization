import SwiftUI

struct DiagramView: View {
    @ObservedObject var fileLoader: FileLoader

    var body: some View {
        HStack(spacing: 20) {
            EnhancedDiagramView(fileLoader: fileLoader)
        }
    }
}
