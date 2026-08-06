import SwiftUI

struct CrosshairView: View {
    var body: some View {
        Image(systemName: "plus")
            .font(.system(size: 44))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .ignoresSafeArea(edges: .leading)
    }
}
