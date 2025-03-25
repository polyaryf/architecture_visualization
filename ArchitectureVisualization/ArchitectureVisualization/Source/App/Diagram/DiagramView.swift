import SwiftUI

struct DiagramView: View {
    @ObservedObject var fileLoader: FileLoader
    
    var body: some View {
        HStack(alignment: .top, spacing: 50) {
            if !fileLoader.pods.isEmpty {
                AllPodsView(fileLoader: fileLoader)
            }
            ScrollView(.horizontal) {
                LazyHStack(spacing: 40) {
                    ForEach(fileLoader.swiftNodes) { swiftNode in
                        LazyVStack(alignment: .leading, spacing: 10) {
                            DynamicRectangleView(
                                conformsToProtocols: String.protocolsStringFrom(swiftNode.conformsTo),
                                name: swiftNode.type.rawValue + " " + swiftNode.name,
                                properties: swiftNode.properties.map { $0.name }
                            )
                        }
                        
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
    }
}

private extension String {
    static func protocolsStringFrom(_ array: [String]) -> String {
        var result: String = ""
        array.forEach { string in
            result += string + " ,"
        }
        return result
    }
}
