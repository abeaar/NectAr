import SwiftUI

/// Tiny vertical-bounce arrow indicator, used as a "tap to continue" hint on
/// the active narration card. The arrow image is supplied by
/// `Cards/arrow.imageset`.
struct FloatingArrow: View {
    @State private var isUp = false

    var body: some View {
        Image("arrow")
            .resizable()
            .scaledToFit()
            .frame(width: 15, height: 21)
            .offset(y: isUp ? -8 : 0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    isUp.toggle()
                }
            }
    }
}

#Preview {
    FloatingArrow()
}
