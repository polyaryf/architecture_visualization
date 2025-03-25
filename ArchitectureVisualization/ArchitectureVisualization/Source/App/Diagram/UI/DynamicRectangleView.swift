import SwiftUI

struct DynamicRectangleView: View {
    let conformsToProtocols: String
    let name: String
    let properties: [String]
    
    var body: some View {
        VStack(spacing: 16) {
            ExpandableSection(title: name) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name: \(name)")
                        .font(.body)
                        .bold()
                        .foregroundColor(.black)
                    ForEach(properties, id: \.self) { string in
                        Text(string)
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            ExpandableSection(title: "Conforms To Protocols") {
                Text(conformsToProtocols)
                    .font(.body)
                    .foregroundColor(.black)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding()
    }
}
