//
//  EdgesView.swift
//  ArchitectureVisualizationTool
//
//  Created by Полина Рыфтина on 12.04.2025.
//

import SwiftUI

struct EdgesView: View {
    let graph: DependencyGraph
    let nodePositions: [String: CGPoint]
    let scale: CGFloat
    let offset: CGSize
    let gridSpacing: CGFloat

    private let nodeSize = CGSize(width: 180, height: 150)

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                for edge in graph.edges {
                    guard let fromCenter = nodePositions[edge.from.name],
                          let toCenter = nodePositions[edge.to.name] else { continue }

                    let fromRect = CGRect(
                        x: fromCenter.x - nodeSize.width / 2,
                        y: fromCenter.y - nodeSize.height / 2,
                        width: nodeSize.width,
                        height: nodeSize.height
                    )

                    let toRect = CGRect(
                        x: toCenter.x - nodeSize.width / 2,
                        y: toCenter.y - nodeSize.height / 2,
                        width: nodeSize.width,
                        height: nodeSize.height
                    )

                    let start = connectionPoint(for: fromRect, to: toCenter)
                    let end = connectionPoint(for: toRect, to: fromCenter)

                    let points = aStarPath(from: start, to: end, nodes: nodePositions.values.map {
                        CGRect(
                            x: $0.x - nodeSize.width / 2,
                            y: $0.y - nodeSize.height / 2,
                            width: nodeSize.width,
                            height: nodeSize.height
                        )
                    })

                    var path = Path()
                    path.move(to: points.first ?? start)

                    for i in 1..<points.count {
                        let midPoint = CGPoint(
                            x: (points[i - 1].x + points[i].x) / 2,
                            y: (points[i - 1].y + points[i].y) / 2
                        )

                        path.addQuadCurve(to: points[i], control: midPoint)
                    }

                    let style: StrokeStyle = {
                        switch edge.ownership {
                        case .strong:
                            return StrokeStyle(lineWidth: 2, lineCap: .round)
                        case .weak, .unowned:
                            return StrokeStyle(lineWidth: 2, dash: [5, 5])
                        }
                    }()

                    let color: Color = {
                        switch edge.ownership {
                        case .strong:
                            return .blue
                        case .weak, .unowned:
                            return .red
                        }
                    }()

                    context.stroke(path, with: .color(color), style: style)

                    drawArrow(context: &context, points: points, color: color)
                }
            }
        }
    }

    private func connectionPoint(for rect: CGRect, to point: CGPoint) -> CGPoint {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let dx = point.x - center.x
        let dy = point.y - center.y

        if abs(dx) > abs(dy) {
            return CGPoint(x: dx > 0 ? rect.maxX : rect.minX, y: center.y)
        } else {
            return CGPoint(x: center.x, y: dy > 0 ? rect.maxY : rect.minY)
        }
    }

    private func drawArrow(context: inout GraphicsContext, points: [CGPoint], color: Color) {
        guard points.count >= 2 else { return }

        let lastPoint = points.last!
        let previousPoint = points[points.count - 2]

        let arrowLength: CGFloat = 10
        let arrowAngle: CGFloat = .pi / 6

        let dx = lastPoint.x - previousPoint.x
        let dy = lastPoint.y - previousPoint.y
        let angle = atan2(dy, dx)

        let arrowPoint1 = CGPoint(
            x: lastPoint.x - arrowLength * cos(angle - arrowAngle),
            y: lastPoint.y - arrowLength * sin(angle - arrowAngle)
        )

        let arrowPoint2 = CGPoint(
            x: lastPoint.x - arrowLength * cos(angle + arrowAngle),
            y: lastPoint.y - arrowLength * sin(angle + arrowAngle)
        )

        var arrowPath = Path()
        arrowPath.move(to: lastPoint)
        arrowPath.addLine(to: arrowPoint1)
        arrowPath.move(to: lastPoint)
        arrowPath.addLine(to: arrowPoint2)

        context.stroke(arrowPath, with: .color(color), lineWidth: 2)
    }
    
    private func aStarPath(from start: CGPoint, to end: CGPoint, nodes: [CGRect]) -> [CGPoint] {
        let gridStep: CGFloat = 50
        let startGrid = CGPoint(x: round(start.x / gridStep), y: round(start.y / gridStep))
        let endGrid = CGPoint(x: round(end.x / gridStep), y: round(end.y / gridStep))
        
        struct GridPoint: Hashable {
            let x: Int
            let y: Int
        }
        
        let startPoint = GridPoint(x: Int(startGrid.x), y: Int(startGrid.y))
        let endPoint = GridPoint(x: Int(endGrid.x), y: Int(endGrid.y))
        
        // 1. Bounding box
        let nodeXs = nodes.flatMap { [Int($0.minX / gridStep), Int($0.maxX / gridStep)] }
        let nodeYs = nodes.flatMap { [Int($0.minY / gridStep), Int($0.maxY / gridStep)] }
        
        let minX = (nodeXs.min() ?? 0) - 5
        let maxX = (nodeXs.max() ?? 0) + 5
        let minY = (nodeYs.min() ?? 0) - 5
        let maxY = (nodeYs.max() ?? 0) + 5
        
        func isWithinBounds(_ point: GridPoint) -> Bool {
            return point.x >= minX && point.x <= maxX && point.y >= minY && point.y <= maxY
        }
        
        var openSet: Set<GridPoint> = [startPoint]
        var cameFrom: [GridPoint: GridPoint] = [:]
        
        var gScore: [GridPoint: CGFloat] = [startPoint: 0]
        var fScore: [GridPoint: CGFloat] = [startPoint: distance(from: (x: startPoint.x, y: startPoint.y), to: (x: endPoint.x, y: endPoint.y))]
        
        let directions = [
            GridPoint(x: 1, y: 0), GridPoint(x: -1, y: 0),
            GridPoint(x: 0, y: 1), GridPoint(x: 0, y: -1)
        ]
        
        func isBlocked(_ point: GridPoint) -> Bool {
            let actualPoint = CGPoint(x: CGFloat(point.x) * gridStep, y: CGFloat(point.y) * gridStep)
            return nodes.contains { $0.contains(actualPoint) }
        }
        
        let maxSteps = 1000 // safety limit
        
        var steps = 0
        
        while !openSet.isEmpty && steps < maxSteps {
            steps += 1
            
            guard let current = openSet.min(by: { fScore[$0, default: .infinity] < fScore[$1, default: .infinity] }) else { break }
            
            if current == endPoint {
                var path: [CGPoint] = []
                var node = current
                
                while let prev = cameFrom[node] {
                    path.append(CGPoint(x: CGFloat(node.x) * gridStep, y: CGFloat(node.y) * gridStep))
                    node = prev
                }
                
                path.append(start)
                return path.reversed() + [end]
            }
            
            openSet.remove(current)
            
            for direction in directions {
                let neighbor = GridPoint(x: current.x + direction.x, y: current.y + direction.y)
                
                if isBlocked(neighbor) || !isWithinBounds(neighbor) { continue }
                
                let tentativeGScore = gScore[current, default: .infinity] + 1
                
                if tentativeGScore < gScore[neighbor, default: .infinity] {
                    cameFrom[neighbor] = current
                    gScore[neighbor] = tentativeGScore
                    fScore[neighbor] = tentativeGScore + distance(from: (x: neighbor.x, y: neighbor.y), to: (x: endPoint.x, y: endPoint.y))
                    openSet.insert(neighbor)
                }
            }
        }
        
        return [start, end]
    }
    
    private func distance(from: (x: Int, y: Int), to: (x: Int, y: Int)) -> CGFloat {
        let dx = CGFloat(from.x - to.x)
        let dy = CGFloat(from.y - to.y)
        return abs(dx) + abs(dy)
    }
}
