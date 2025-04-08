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
            let layout = generateLayout(from: fileLoader.swiftNodes, in: geometry)
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                ZStack {
                    if !fileLoader.pods.isEmpty {
                        AllPodsView(fileLoader: fileLoader)
                            .position(x: -100, y: -100)
                    }
                    Color.clear
                    ZStack {
                        ForEach(fileLoader.swiftNodes) { node in
                            EnhancedNodeView(node: node)
                                .frame(maxWidth: 360)
                                .background(Color.clear)
                                .background(NodeGeometryReader(id: node.name, frames: $nodeFrames))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(selectedNode == node.name ? Color.accentColor : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    withAnimation {
                                        selectedNode = selectedNode == node.name ? nil : node.name
                                    }
                                }
                                .position(layout[node.name, default: .zero])
                        }
                    }

                    // 🎯 Стрелки
                    if !nodeFrames.isEmpty {
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
                        .frame(width: 3000, height: 3000)
                        .scaleEffect(scale)
                        .offset(x: offset.width + gestureOffset.width, y: offset.height + gestureOffset.height)
                    }
                }
                .frame(width: 3000, height: 3000)
                .scaleEffect(scale)
                .offset(x: offset.width + gestureOffset.width, y: offset.height + gestureOffset.height)
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
            .coordinateSpace(name: "diagramSpace")
        }
    }
}

func generateLayout(from nodes: [SwiftNode], in geometry: GeometryProxy) -> [String: CGPoint] {
    let nodeWidth: CGFloat = 400
    let nodeHeight: CGFloat = 320
    let spacingX: CGFloat = 80
    let spacingY: CGFloat = 80

    let availableWidth = geometry.size.width
    let columns = max(Int(availableWidth / (nodeWidth + spacingX)), 2)

    var layout: [String: CGPoint] = [:]

    for (i, node) in nodes.enumerated() {
        let col = i % columns
        let row = i / columns

        let x = CGFloat(col) * (nodeWidth + spacingX) + nodeWidth / 2
        let y = CGFloat(row) * (nodeHeight + spacingY) + nodeHeight / 2

        layout[node.name] = CGPoint(x: x, y: y)
    }

    return layout
}
