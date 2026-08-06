import SwiftUI

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        HStack {
            Button(action: action) {
                Image(systemName: "chevron.left")
                    .padding()
                    .background(.black.opacity(0.6))
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }
            .padding(.leading, 31)
            .padding(.top, 31)
            Spacer()
        }
        .ignoresSafeArea(edges: .leading)
    }
}
