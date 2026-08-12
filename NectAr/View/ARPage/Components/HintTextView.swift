import SwiftUI

struct HintTextView: View {
    let hintText: String

    var body: some View {
        Text(hintText)
            .padding()
            .background(.black.opacity(0.6))
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .padding(.top, 60)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .leading)
    }
}
