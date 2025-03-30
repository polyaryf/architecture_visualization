import SwiftUI

struct NodeGeometryReader: View {
    let id: String
    @Binding var frames: [String: CGRect]
    
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .preference(key: NodeFramePreferenceKey.self, value: [id: geo.frame(in: .named("diagramSpace"))])
        }
        .onPreferenceChange(NodeFramePreferenceKey.self) { value in
            frames.merge(value) { $1 }
        }
    }
}

struct NodeFramePreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
