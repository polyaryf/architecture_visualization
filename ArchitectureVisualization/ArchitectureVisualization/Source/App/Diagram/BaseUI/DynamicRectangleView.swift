import SwiftUI

struct DynamicRectangleView: View {
    let conformsToProtocols: String
    let name: String
    let properties: [String]

    var body: some View {
        VStack(spacing: 16) {
            ExpandableSection(title: name) {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Name: \(name)", systemImage: "doc.plaintext")
                        .font(.body)
                        .foregroundColor(.black)
                        .padding(.bottom, 4)

                    ForEach(properties, id: \ .self) { string in
                        Label(string, systemImage: "circle.fill")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }
            }

            ExpandableSection(title: "Conforms To") {
                Text(conformsToProtocols)
                    .font(.body)
                    .foregroundColor(.black)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .frame(minWidth: 250)
    }
}
