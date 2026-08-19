import SwiftUI

struct HintTextView: View {
    let hintText: String

    var body: some View {
        ZStack {
            Image("PrepExplainCard")
                .resizable()
                .scaledToFit().frame(width: 700)

            Text(hintText)
                .font(.custom("Fredoka-Medium", size: 22, relativeTo: .title2))
                .frame(width: 510, height: 80, alignment: .topLeading)
                .offset(x: 90, y: 10)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

#Preview {
    let sample = PrepExplainCatalog.all[0]
    HintTextView(hintText: sample.description)
}
