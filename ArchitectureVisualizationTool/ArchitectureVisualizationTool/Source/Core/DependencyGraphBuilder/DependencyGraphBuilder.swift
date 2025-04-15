//
//  DependencyGraphBuilder.swift
//  ArchitectureVisualizationTool
//
//  Created by Полина Рыфтина on 12.04.2025.
//

import Foundation

class DependencyGraphBuilder {

    func buildGraph(classNodes: [ClassNode], enumNodes: [EnumNode]) -> DependencyGraph {
        var allComponents = Set(classNodes.map { $0.name } + enumNodes.map { $0.name })
        var nodes = Set<GraphNode>()
        var edges = Set<GraphEdge>()

        let protocolImplementations = buildProtocolImplementations(
            classNodes: classNodes,
            enumNodes: enumNodes
        )

        // Добавляем все компоненты как узлы графа
        for name in allComponents {
            nodes.insert(GraphNode(name: name))
        }

        // Строим связи для классов
        for classNode in classNodes {
            let currentNode = GraphNode(name: classNode.name)

            for property in classNode.properties {
                addEdge(
                    from: currentNode,
                    propertyType: property.type,
                    ownership: property.ownership,
                    protocolImplementations: protocolImplementations,
                    edges: &edges, 
                    allComponents: allComponents
                )
            }
        }

        // Enum (если нужно)
        for enumNode in enumNodes {
            let currentNode = GraphNode(name: enumNode.name)

            for property in enumNode.properties {
                addEdge(
                    from: currentNode,
                    propertyType: property.type,
                    ownership: property.ownership,
                    protocolImplementations: protocolImplementations,
                    edges: &edges,
                    allComponents: allComponents
                )
            }
        }

        return DependencyGraph(nodes: nodes, edges: edges)
    }

    private func addEdge(
        from node: GraphNode,
        propertyType: String,
        ownership: Ownership,
        protocolImplementations: [String: [String]],
        edges: inout Set<GraphEdge>,
        allComponents: Set<String>
    ) {
        var propertyType = propertyType
        propertyType.removeAll(where: { $0 == "?" })
        if allComponents.contains(propertyType) {
            edges.insert(GraphEdge(from: node, to: GraphNode(name: propertyType), ownership: ownership))
        } else if let implementations = protocolImplementations[propertyType] {
            for implementation in implementations {
                edges.insert(GraphEdge(from: node, to: GraphNode(name: implementation), ownership: ownership))
            }
        }
    }

    private func buildProtocolImplementations(classNodes: [ClassNode], enumNodes: [EnumNode]) -> [String: [String]] {
        var map: [String: [String]] = [:]

        for classNode in classNodes {
            for proto in classNode.protocols {
                map[proto, default: []].append(classNode.name)
            }
        }

        for enumNode in enumNodes {
            for proto in enumNode.protocols {
                map[proto, default: []].append(enumNode.name)
            }
        }

        return map
    }
}
