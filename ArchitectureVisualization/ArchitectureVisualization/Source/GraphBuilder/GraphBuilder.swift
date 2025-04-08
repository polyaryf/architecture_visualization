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
    let to: String
    let type: RelationshipArrow
}

/// Построитель ориентированного графа архитектурных связей
struct GraphBuilder {

    /// Строит граф из массива SwiftNode
    static func build(from nodes: [SwiftNode]) -> [String: [Edge]] {
        var graph: [String: [Edge]] = [:]
        let allNodeNames = Set(nodes.map { $0.name })

        for node in nodes {
            var edges: [Edge] = []

            for relationship in node.relationships {
                let target = relationship.to
                guard allNodeNames.contains(target) else { continue }

                let arrowType: RelationshipArrow = mapType(
                    source: node,
                    targetName: target,
                    relationship: relationship
                )

                edges.append(Edge(to: target, type: arrowType))
            }

            graph[node.name] = edges
        }

        return graph
    }

    /// Маппинг типа связи на визуальный тип стрелки
    private static func mapType(
        source: SwiftNode,
        targetName: String,
        relationship: SwiftRelationship
    ) -> RelationshipArrow {
        switch relationship.type {
        case .inheritance:
            return .inheritance

        case .aggregation:
            return .aggregation

        case .composition:
            return .composition

        case .reference(let strength):
            switch strength {
            case .strong:
                return .referenceStrong
            case .weak:
                return .referenceWeak
            case .unowned:
                return .referenceUnowned
            }
        }
    }
}
