import Foundation

func generateLayoutHierarchical(from nodes: [SwiftNode]) -> [String: CGPoint] {
    let graph = GraphBuilder.build(from: nodes)

    var reverseGraph: [String: [String]] = [:]
    for (from, edges) in graph {
        for edge in edges {
            reverseGraph[edge.to, default: []].append(from)
        }
    }

    let allNames = Set(nodes.map { $0.name })
    let targets = Set(reverseGraph.keys)
    let rootNames = allNames.subtracting(targets)

    var level: [String: Int] = [:]
    var queue: [(String, Int)] = rootNames.map { ($0, 0) }

    while let (current, l) = queue.first {
        queue.removeFirst()
        if level[current] != nil { continue }
        level[current] = l
        for edge in graph[current] ?? [] {
            queue.append((edge.to, l + 1))
        }
    }

    let maxLevel = (level.values.max() ?? 0)
    var levels: [[String]] = Array(repeating: [], count: maxLevel + 1)
    for (name, l) in level {
        levels[l].append(name)
    }

    // Размещение с центровкой
    let nodeWidth: CGFloat = 400
    let nodeHeight: CGFloat = 300
    let spacingX: CGFloat = 80
    let spacingY: CGFloat = 200

    var layout: [String: CGPoint] = [:]

    for (l, names) in levels.enumerated() {
        let count = names.count
        let totalWidth = CGFloat(count) * (nodeWidth + spacingX) - spacingX
        let startX: CGFloat = (3000 - totalWidth) / 2

        for (i, name) in names.enumerated() {
            let x = startX + CGFloat(i) * (nodeWidth + spacingX) + nodeWidth / 2
            let y = CGFloat(l) * (nodeHeight + spacingY) + nodeHeight / 2 + 100
            layout[name] = CGPoint(x: x, y: y)
        }
    }

    return layout
}
