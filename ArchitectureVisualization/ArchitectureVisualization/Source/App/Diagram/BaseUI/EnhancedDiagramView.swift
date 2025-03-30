import SwiftUI

struct EnhancedDiagramView: View {
    @ObservedObject var fileLoader: FileLoader

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @GestureState private var gestureOffset: CGSize = .zero
    @State private var nodeFrames: [String: CGRect] = [:]
    @State private var selectedNode: String? = nil

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(fileLoader.swiftNodes) { node in
                            EnhancedNodeView(node: node)
                                .background(NodeGeometryReader(id: node.name, frames: $nodeFrames))
                                .padding(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(selectedNode == node.name ? Color.accentColor : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    withAnimation {
                                        selectedNode = selectedNode == node.name ? nil : node.name
                                    }
                                }
                        }
                    }
                    .padding()
                    .scaleEffect(scale)
                    .offset(x: offset.width + gestureOffset.width, y: offset.height + gestureOffset.height)
                    .animation(.spring(), value: scale)
                    .gesture(
                        DragGesture()
                            .updating($gestureOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onEnded { value in
                                offset.width += value.translation.width
                                offset.height += value.translation.height
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = min(max(0.5, scale * value), 2.5)
                            }
                    )
                }

                // Отрисовка стрелок
                Canvas { context, _ in
                    let graph = GraphBuilder.build(from: fileLoader.swiftNodes)

                    for (from, edges) in graph {
                        guard let fromFrame = nodeFrames[from] else { continue }
                        let fromPoint = CGPoint(x: fromFrame.maxX, y: fromFrame.midY)

                        for edge in edges {
                            guard let toFrame = nodeFrames[edge.to] else { continue }
                            let toPoint = CGPoint(x: toFrame.minX, y: toFrame.midY)

                            let arrow = UMLArrowPath(start: fromPoint, end: toPoint, type: edge.type)
                            let isHighlighted = selectedNode == nil || selectedNode == from || selectedNode == edge.to
                            let color = isHighlighted ? arrow.color : arrow.color.opacity(0.2)
                            let style = isHighlighted ? arrow.style : StrokeStyle(lineWidth: 1, dash: [2, 6])

                            context.stroke(arrow.path, with: .color(color), style: style)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                UMLControlPanel(scale: $scale, offset: $offset)
                    .padding()
            }
        }
    }
}

// Чтение геометрии каждой ноды
struct NodeGeometryReader: View {
    let id: String
    @Binding var frames: [String: CGRect]

    var body: some View {
        GeometryReader { geo in
            Color.clear
                .preference(key: NodeFramePreferenceKey.self, value: [id: geo.frame(in: .named("diagramSpace"))])
        }
        .onPreferenceChange(NodeFramePreferenceKey.self) { value in
            frames.merge(value) { $1 }
        }
    }
}

struct NodeFramePreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// Для построения стрелки
struct UMLArrowPath {
    let path: Path
    let color: Color
    let style: StrokeStyle

    init(start: CGPoint, end: CGPoint, type: RelationshipArrow) {
        var p = Path()
        p.move(to: start)
        p.addLine(to: CGPoint(x: start.x + 40, y: start.y))
        p.addLine(to: CGPoint(x: end.x - 10, y: end.y))
        p.addLine(to: end)

        let arrowSize: CGFloat = 10
        let arrowTip1 = CGPoint(x: end.x - arrowSize, y: end.y - arrowSize / 2)
        let arrowTip2 = CGPoint(x: end.x - arrowSize, y: end.y + arrowSize / 2)
        p.move(to: end)
        p.addLine(to: arrowTip1)
        p.move(to: end)
        p.addLine(to: arrowTip2)

        self.path = p

        switch type {
        case .inheritance:
            self.color = .black
            self.style = StrokeStyle(lineWidth: 2)
        case .composition:
            self.color = .brown
            self.style = StrokeStyle(lineWidth: 2)
        case .aggregation:
            self.color = .gray
            self.style = StrokeStyle(lineWidth: 1.5, dash: [4, 4])
        case .referenceStrong:
            self.color = .blue
            self.style = StrokeStyle(lineWidth: 1.5)
        case .referenceWeak:
            self.color = .orange
            self.style = StrokeStyle(lineWidth: 1.2, dash: [2, 4])
        case .referenceUnowned:
            self.color = .red
            self.style = StrokeStyle(lineWidth: 1.2, dash: [1, 3])
        }
    }
}
