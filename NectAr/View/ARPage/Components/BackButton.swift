import SwiftUI

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        HStack {
            Button(action: action) {
                Image("BackButton2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55)
            }
            .padding(.leading, 24)
            .padding(.top, 16)
            Spacer()
        }
        .ignoresSafeArea(edges: .leading)
    }
}
