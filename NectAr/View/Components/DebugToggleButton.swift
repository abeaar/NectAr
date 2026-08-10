import SwiftUI

struct DebugToggleButton: View {
    @Binding var isDebugModeOn: Bool

    var body: some View {
        HStack {
            Spacer()
            Button {
                isDebugModeOn.toggle()
            } label: {
                Image(systemName: isDebugModeOn ? "eye" : "eye.slash")
                    .padding()
                    .background(.black.opacity(0.6))
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }
            .padding(.trailing, 20)
            .padding(.top, 60)
        }
    }
}
