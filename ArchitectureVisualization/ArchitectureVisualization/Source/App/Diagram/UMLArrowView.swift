import SwiftUI

struct UMLArrowView: View {
    var start: CGPoint
    var end: CGPoint
    var type: RelationshipArrow

    var body: some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: CGPoint(x: start.x + 40, y: start.y))
            path.addLine(to: CGPoint(x: end.x - 10, y: end.y))

            // Arrow head
            let arrowSize: CGFloat = 10
            let arrowTip1 = CGPoint(x: end.x - arrowSize, y: end.y - arrowSize / 2)
            let arrowTip2 = CGPoint(x: end.x - arrowSize, y: end.y + arrowSize / 2)

            path.addLine(to: end)
            path.move(to: end)
            path.addLine(to: arrowTip1)
            path.move(to: end)
            path.addLine(to: arrowTip2)
        }
        .stroke(style: strokeStyle(for: type))
        .foregroundColor(color(for: type))
    }

    private func strokeStyle(for type: RelationshipArrow) -> StrokeStyle {
        switch type {
        case .inheritance:
            return StrokeStyle(lineWidth: 2, dash: [])
        case .composition:
            return StrokeStyle(lineWidth: 2, dash: [])
        case .aggregation:
            return StrokeStyle(lineWidth: 1.5, dash: [4, 4])
        case .referenceStrong:
            return StrokeStyle(lineWidth: 1.5, dash: [])
        case .referenceWeak:
            return StrokeStyle(lineWidth: 1.2, dash: [2, 4])
        case .referenceUnowned:
            return StrokeStyle(lineWidth: 1.2, dash: [1, 3])
        }
    }

    private func color(for type: RelationshipArrow) -> Color {
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
}

struct UMLArrowPath {
    let path: Path
    let color: Color
    let style: StrokeStyle

    init(start: CGPoint, end: CGPoint, type: RelationshipArrow) {
        var p = Path()

        let midX = (start.x + end.x) / 2
        let control = CGPoint(x: midX, y: min(start.y, end.y) - 40)

        p.move(to: start)
        p.addQuadCurve(to: end, control: control)

        // стрелочка
        let arrowSize: CGFloat = 10
        let dx = end.x - start.x
        let dy = end.y - start.y
        let angle = atan2(dy, dx)
        let arrowTip1 = CGPoint(x: end.x - cos(angle - .pi / 6) * arrowSize,
                                y: end.y - sin(angle - .pi / 6) * arrowSize)
        let arrowTip2 = CGPoint(x: end.x - cos(angle + .pi / 6) * arrowSize,
                                y: end.y - sin(angle + .pi / 6) * arrowSize)

        p.move(to: end)
        p.addLine(to: arrowTip1)
        p.move(to: end)
        p.addLine(to: arrowTip2)

        self.path = p

        switch type {
        case .inheritance:
            color = .black
            style = StrokeStyle(lineWidth: 2)
        case .composition:
            color = .brown
            style = StrokeStyle(lineWidth: 2)
        case .aggregation:
            color = .gray
            style = StrokeStyle(lineWidth: 1.5, dash: [4, 4])
        case .referenceStrong:
            color = .blue
            style = StrokeStyle(lineWidth: 1.5)
        case .referenceWeak:
            color = .orange
            style = StrokeStyle(lineWidth: 1.2, dash: [2, 4])
        case .referenceUnowned:
            color = .red
            style = StrokeStyle(lineWidth: 1.2, dash: [1, 3])
        }
    }
}
