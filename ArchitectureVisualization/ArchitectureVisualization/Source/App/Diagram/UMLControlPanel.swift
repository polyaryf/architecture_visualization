import SwiftUI

struct UMLControlPanel: View {
    @Binding var scale: CGFloat
    @Binding var offset: CGSize

    var body: some View {
        HStack {
            Button(action: { withAnimation { scale += 0.1 } }) {
                Image(systemName: "plus.magnifyingglass")
                    .padding()
                    .background(Circle().fill(Color.purple).shadow(radius: 2))
            }

            Button(action: { withAnimation { scale -= 0.1 } }) {
                Image(systemName: "minus.magnifyingglass")
                    .padding()
                    .background(Circle().fill(Color.purple).shadow(radius: 2))
            }

            Button(action: { withAnimation { scale = 1.0; offset = .zero } }) {
                Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                    .padding()
                    .background(Circle().fill(Color.purple).shadow(radius: 2))
            }
        }
        .padding()
    }
}
