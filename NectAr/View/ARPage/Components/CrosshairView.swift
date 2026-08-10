import SwiftUI

struct CrosshairView: View {
    var body: some View {
        // White cross over a slightly larger black one, so the reticle stays readable
        // against both light and dark surfaces in the camera feed.
        ZStack {
            ZStack {
                Rectangle().frame(width: 25, height: 6)
                Rectangle().frame(width: 6, height: 25)
            }
            .foregroundStyle(.black)

            ZStack {
                Rectangle().frame(width: 21, height: 2)
                Rectangle().frame(width: 2, height: 21)
            }
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .ignoresSafeArea(edges: .leading)
    }
}
