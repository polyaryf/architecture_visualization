//
//  PodView.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 12.02.2025.
//

import SwiftUI

struct PodView: View {
    let pod: PodNode

    var body: some View {
        HStack {
            Text(pod.name)
                .font(.headline)
                .foregroundColor(.blue)

            Text("v\(pod.version)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 3)
    }
}

