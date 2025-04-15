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

                    // Узлы (ноды)
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

                    // Стрелки
                    if !nodeFrames.isEmpty {
                        Canvas { context, _ in
                            let graph = GraphBuilder.build(from: fileLoader.swiftNodes)
                            print("Graph nodes: \(graph.keys)")
                            let cellSize = calculateDynamicCellSize(from: nodeFrames, in: geometry.size)
                            let nodeGridPositions = calculateNodeGridPositions(nodeFrames: nodeFrames, cellSize: cellSize)

                            for (from, edges) in graph {
                                guard let fromGrid = nodeGridPositions[from] else { continue }

                                for edge in edges {
                                    guard let toGrid = nodeGridPositions[edge.to] else { continue }

                                    let pathPoints = manhattanPath(from: fromGrid, to: toGrid)

                                    var path = Path()
                                    if let startPoint = pathPoints.first {
                                        path.move(to: pointForGridPosition(startPoint, cellSize: cellSize))

                                        for gridPoint in pathPoints.dropFirst() {
                                            path.addLine(to: pointForGridPosition(gridPoint, cellSize: cellSize))
                                        }
                                    }

                                    let isHighlighted = selectedNode == nil || selectedNode == from || selectedNode == edge.to
                                    let color = isHighlighted ? colorForRelationship(edge.type) : colorForRelationship(edge.type).opacity(0.2)
                                    let style = isHighlighted ? styleForRelationship(edge.type) : StrokeStyle(lineWidth: 1, dash: [2, 6])

                                    context.stroke(path, with: .color(color), style: style)
                                }
                            }
                        }
                        .frame(width: geometry.size.width * 2, height: geometry.size.height * 2)
                        .scaleEffect(scale)
                        .offset(x: offset.width + gestureOffset.width, y: offset.height + gestureOffset.height)
                    }
                }
                .frame(width: geometry.size.width * 2, height: geometry.size.height * 2)
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

    // MARK: - Utils

    private func pointForGridPosition(_ position: GridPosition, cellSize: CGSize) -> CGPoint {
        CGPoint(
            x: CGFloat(position.column) * cellSize.width + cellSize.width / 2,
            y: CGFloat(position.row) * cellSize.height + cellSize.height / 2
        )
    }

    private func calculateDynamicCellSize(from frames: [String: CGRect], in containerSize: CGSize) -> CGSize {
        // Приблизительный размер клетки исходя из средней ширины/высоты узлов
        let totalNodes = frames.count
        let estimatedColumns = max(Int(containerSize.width / 300), 2)
        let estimatedRows = max(totalNodes / estimatedColumns, 2)

        let width = containerSize.width / CGFloat(estimatedColumns)
        let height = containerSize.height / CGFloat(estimatedRows)

        return CGSize(width: width, height: height)
    }

    private func calculateNodeGridPositions(nodeFrames: [String: CGRect], cellSize: CGSize) -> [String: GridPosition] {
        var positions: [String: GridPosition] = [:]
        for (name, frame) in nodeFrames {
            positions[name] = frame.gridPosition(cellSize: cellSize)
        }
        return positions
    }

    private func manhattanPath(from start: GridPosition, to end: GridPosition) -> [GridPosition] {
        var path: [GridPosition] = []
        var current = start

        while current.column != end.column {
            current = GridPosition(row: current.row, column: current.column + (current.column < end.column ? 1 : -1))
            path.append(current)
        }

        while current.row != end.row {
            current = GridPosition(row: current.row + (current.row < end.row ? 1 : -1), column: current.column)
            path.append(current)
        }

        return path
    }
}

// MARK: - Layout Calculation

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

// MARK: - Relationship Styling

func colorForRelationship(_ type: RelationshipArrow) -> Color {
    switch type {
    case .inheritance:
        return .black
    case .composition:
        return .brown
    case .aggregation:
        return .gray
    case .referenceStrong:
        return .blue
    case .referenceWeak:
        return .orange
    case .referenceUnowned:
        return .red
    }
}

func styleForRelationship(_ type: RelationshipArrow) -> StrokeStyle {
    switch type {
    case .inheritance:
        return StrokeStyle(lineWidth: 2)
    case .composition:
        return StrokeStyle(lineWidth: 2)
    case .aggregation:
        return StrokeStyle(lineWidth: 1.5, dash: [4, 4])
    case .referenceStrong:
        return StrokeStyle(lineWidth: 1.5)
    case .referenceWeak:
        return StrokeStyle(lineWidth: 1.2, dash: [2, 4])
    case .referenceUnowned:
        return StrokeStyle(lineWidth: 1.2, dash: [1, 3])
    }
}
