import SwiftUI

struct ExpandableSection<Content: View>: View {
    @State private var isExpanded = false
    
    let title: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { isExpanded.toggle() }
            }) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(12)
                .shadow(color: Color.purple.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .cornerRadius(12)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    content()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(white: 0.95)))
                .shadow(radius: 4)
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding()
            }
        }
    }
}
