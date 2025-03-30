import SwiftUI

struct ExpandableSection<Content: View>: View {
    @State private var isExpanded = false
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Label(title, systemImage: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(LinearGradient(
                    gradient: Gradient(colors: [Color.teal, Color.blue]),
                    startPoint: .leading,
                    endPoint: .trailing)
                )
                .cornerRadius(14)
                .shadow(color: Color.teal.opacity(0.3), radius: 5, x: 0, y: 3)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    content
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 14).fill(Color(white: 0.96)))
                .shadow(radius: 3)
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 4)
            }
        }
    }
}
