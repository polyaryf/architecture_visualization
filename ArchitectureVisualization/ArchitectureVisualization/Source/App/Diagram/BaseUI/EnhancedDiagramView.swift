import SwiftUI

struct EnhancedDiagramView: View {
    @ObservedObject var fileLoader: FileLoader
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @GestureState private var gestureOffset: CGSize = .zero
    @State private var nodeFrames: [String: CGRect] = [:]
    @State private var selectedNode: String? = nil
    @State private var layout: [String: CGPoint] = [:]
    
    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            ZStack {
                Color.clear
                
                // layoutArea содержит стрелки и узлы
                ZStack {
                    // 🔁 Стрелки
                    if !nodeFrames.isEmpty {
                        Canvas { context, _ in
                            let graph = GraphBuilder.build(from: fileLoader.swiftNodes)
                            
                            for (from, edges) in graph {
                                guard let fromFrame = nodeFrames[from] else { continue }
                                let fromPoint = CGPoint(x: fromFrame.maxX, y: fromFrame.midY)
                                
                                for edge in edges {
                                    guard let toFrame = nodeFrames[edge.to] else { continue }
                                    let toPoint = CGPoint(x: toFrame.minX, y: toFrame.midY)
                                    
                                    // Красивая кривая
                                    var path = Path()
                                    path.move(to: fromPoint)
                                    let controlX = (fromPoint.x + toPoint.x) / 2
                                    let controlY = min(fromPoint.y, toPoint.y) - 40
                                    let control = CGPoint(x: controlX, y: controlY)
                                    path.addQuadCurve(to: toPoint, control: control)
                                    
                                    let arrow = UMLArrowPath(start: fromPoint, end: toPoint, type: edge.type)
                                    
                                    let isHighlighted = selectedNode == nil || selectedNode == from || selectedNode == edge.to
                                    let color = isHighlighted ? arrow.color : arrow.color.opacity(0.2)
                                    let style = isHighlighted ? arrow.style : StrokeStyle(lineWidth: 1, dash: [2, 6])
                                    
                                    context.stroke(path, with: .color(color), style: style)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    // 🔲 Узлы
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
                .frame(width: 3000, height: 3000)
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
            .frame(width: 3000, height: 3000)
        }
        .coordinateSpace(name: "diagramSpace")
        .onAppear {
            layout = generateLayoutHierarchical(from: fileLoader.swiftNodes)
        }
    }
}
