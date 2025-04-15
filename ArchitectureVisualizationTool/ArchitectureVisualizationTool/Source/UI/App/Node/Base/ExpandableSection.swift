//
//  ExpandableSection.swift
//  ArchitectureVisualizationTool
//
//  Created by Полина Рыфтина on 15.04.2025.
//

import SwiftUI

struct ExpandableSection<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    @State private var isExpanded = false
    let title: String
    let data: Data
    let content: (Data.Element) -> Content

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
                    ForEach(data) { element in
                        content(element)
                    }
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

