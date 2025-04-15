import Foundation

/// Тип стрелки для визуализации связи
enum RelationshipArrow: String {
    case aggregation   // Value type (struct, enum)
    case composition   // Создается внутри и владеет
    case inheritance   // Суперкласс или протокол
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

        // Создаем словарь узлов для быстрого доступа
        let nodeDict = nodes.reduce(into: [String: SwiftNode]()) { dict, node in
            if dict[node.name] == nil {
                dict[node.name] = node
            }
        }

        for node in nodes {
            var edges: [Edge] = []

            for relationship in node.relationships {
                let target = relationship.to

                // Проверяем, есть ли целевой узел в словаре
                if let targetNode = nodeDict[target] {
                    let arrowType = mapType(relationship: relationship)
                    edges.append(Edge(to: targetNode.name, type: arrowType))
                } else {
                    // 🧩 Дополнительно: проверяем, нет ли протокола с таким именем
                    let protocolNodes = nodes.filter { $0.type == .protocolType  && $0.name == target }
                    for protoNode in protocolNodes {
                        let arrowType = mapType(relationship: relationship)
                        edges.append(Edge(to: protoNode.name, type: arrowType))
                    }
                }
            }

            // Добавляем связи наследования
            if node.type == .class || node.type == .struct {
                for parent in node.conformsTo {
                    if let parentNode = nodeDict[parent] {
                        edges.append(Edge(to: parentNode.name, type: .inheritance))
                    }
                }
            }

            graph[node.name] = edges
        }

        print("✅ Graph nodes: \(graph.keys)")
        return graph
    }

    /// Маппинг типа связи на визуальный тип стрелки
    private static func mapType(relationship: SwiftRelationship) -> RelationshipArrow {
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
