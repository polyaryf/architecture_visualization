import Foundation

func buildRelationships(for node: SwiftNode, in allNodes: [SwiftNode]) -> [SwiftRelationship] {
    var relationships: [SwiftRelationship] = []

    let nodeDict = allNodes.reduce(into: [String: SwiftNode]()) { dict, node in
        if dict[node.name] == nil {
            dict[node.name] = node
        }
    }

    for property in node.properties {
        let propertyType = property.type

        if let targetNode = nodeDict[propertyType] {
            relationships.append(SwiftRelationship(
                from: node.name,
                to: targetNode.name,
                type: .reference(strength: .strong)
            ))
        }

        let conformingNodes = nodeDict.values.filter { $0.conformsTo.contains(propertyType) }
        for conformer in conformingNodes {
            relationships.append(SwiftRelationship(
                from: node.name,
                to: conformer.name,
                type: .reference(strength: .strong)
            ))
        }
    }

    for function in node.functions {
        for param in function.parameters {
            if let targetNode = nodeDict[param.type] {
                relationships.append(SwiftRelationship(
                    from: node.name,
                    to: targetNode.name,
                    type: .aggregation
                ))
            }
        }
    }

    return relationships
}
