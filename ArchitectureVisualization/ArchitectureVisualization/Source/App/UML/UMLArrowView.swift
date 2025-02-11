//
//  UMLArrowView.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 10.02.2025.
//

import SwiftUI

struct UMLArrowView: View {
    var start: CGPoint
    var end: CGPoint

    var body: some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: CGPoint(x: start.x + 40, y: start.y))
            path.addLine(to: CGPoint(x: end.x - 10, y: end.y))

            let arrowSize: CGFloat = 10
            let arrowTip1 = CGPoint(x: end.x - arrowSize, y: end.y - arrowSize / 2)
            let arrowTip2 = CGPoint(x: end.x - arrowSize, y: end.y + arrowSize / 2)

            path.addLine(to: end)
            path.move(to: end)
            path.addLine(to: arrowTip1)
            path.move(to: end)
            path.addLine(to: arrowTip2)
        }
        .stroke(Color.black.opacity(0.8), style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
    }
}
