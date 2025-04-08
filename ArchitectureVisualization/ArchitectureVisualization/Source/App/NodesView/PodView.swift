import AppKit
import SwiftUI

struct AllPodsView: View {
    @ObservedObject var fileLoader: FileLoader
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("CocoaPods")
                .font(.headline)
                .foregroundColor(.white)
                .padding()

            ForEach(fileLoader.pods, id: \.name) { pod in
                HStack {
                    PodView(pod: pod)
                }
                .padding(6)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

private struct PodView: View {
    let pod: PodNode

    var body: some View {
        HStack {
            Text(pod.name)
                .font(.headline)
                .foregroundColor(.blue)

            Text("\(pod.version)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 3)
    }
}
