import SwiftUI

struct HintTextView: View {
    let hintText: String
    var showsArrow: Bool = true

    var body: some View {
        ZStack {
            Image("PrepExplainCard2")
                .resizable()
                .scaledToFit().frame(width: 700)

            Text(hintText)
                .font(.custom("Fredoka-Medium", size: 22, relativeTo: .title2))
                .frame(width: 510, height: 80, alignment: .topLeading)
                .offset(x: 90, y: 10)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .overlay(alignment: .bottomTrailing) {
            if showsArrow {
                FloatingArrow()
                    .padding(.trailing, 55)
                    .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    let sample = PrepExplainCatalog.all[0]
    HintTextView(hintText: sample.description)
}
