import Foundation

/// Тип связи между сущностями
enum RelationshipArrow: String {
    case aggregation   // value type (struct, enum)
    case composition   // created inside and owned
    case inheritance   // superclass or protocol
    case referenceStrong
    case referenceWeak
    case referenceUnowned
}

/// Ребро графа
struct Edge {
    let from: String
    let to: String
    let type: RelationshipArrow
}

import Foundation

struct GraphBuilder {
    static func build(from nodes: [SwiftNode]) -> [String: [Edge]] {
        var graph: [String: [Edge]] = [:]

        // Надёжный способ создать nodeDict без краша
        let nodeDict = nodes.reduce(into: [String: SwiftNode]()) { dict, node in
            if dict[node.name] == nil {
                dict[node.name] = node
            } else {
                print("⚠️ Duplicate node name detected: \(node.name)")
            }
        }

        for node in nodes {
            var edges: [Edge] = []

            for property in node.properties {
                let relation = referenceType(for: property)

                if let referenced = nodeDict[property.type] {
                    edges.append(Edge(from: referenced.name, to: node.name, type: relation))
                }

                let conforming = nodes.filter { $0.conformsTo.contains(property.type) }
                for conf in conforming {
                    edges.append(Edge(from: conf.name, to: node.name, type: relation))
                }
            }

            if let superClass = node.inheritsFrom {
                edges.append(Edge(from: superClass, to: node.name, type: .inheritance))
            }

            graph[node.name] = edges
        }

        return graph
    }

    private static func referenceType(for property: SwiftProperty) -> RelationshipArrow {
        switch property.modifier {
        case .weak: return .referenceWeak
        case .unowned: return .referenceUnowned
        default: return .referenceStrong
        }
    }
}
