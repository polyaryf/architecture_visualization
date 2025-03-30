import SwiftUI

struct DiagramView: View {
    @ObservedObject var fileLoader: FileLoader

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @GestureState private var draggingOffset: CGSize = .zero

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(white: 0.95)
                .edgesIgnoringSafeArea(.all)

            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    if !fileLoader.pods.isEmpty {
                        AllPodsView(fileLoader: fileLoader)
                            .padding(.bottom, 20)
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 30)], spacing: 40) {
                        ForEach(fileLoader.swiftNodes) { swiftNode in
                            DynamicRectangleView(
                                conformsToProtocols: String.protocolsStringFrom(swiftNode.conformsTo),
                                name: swiftNode.type.rawValue + " " + swiftNode.name,
                                properties: swiftNode.properties.map { $0.name }
                            )
                        }
                    }
                }
                .scaleEffect(scale)
                .offset(x: offset.width + draggingOffset.width, y: offset.height + draggingOffset.height)
                .gesture(dragGesture)
                .gesture(magnificationGesture)
                .animation(.easeInOut(duration: 0.3), value: scale)
                .animation(.spring(), value: offset)
            }

            UMLControlPanel(scale: $scale, offset: $offset)
                .padding()
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($draggingOffset) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                offset.width += value.translation.width
                offset.height += value.translation.height
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { newScale in
                scale = min(max(newScale, 0.5), 3.0)
            }
    }
}

private extension String {
    static func protocolsStringFrom(_ array: [String]) -> String {
        array.joined(separator: ", ")
    }
}
