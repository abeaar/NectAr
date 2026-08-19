//
//  PrepOnboardExplanationCard.swift
//  NectAr
//

import SwiftUI

/// Narration card for the preparation phase's bee-hunt intro, steps 1-2.
struct PrepOnboardExplanationCard: View {
    var description: String

    var body: some View {
        ZStack {
            Image("PrepOnboardCard")

            Text(description)
                .font(Font.custom("Fredoka-Medium", size: 24, relativeTo: .body))
                .foregroundStyle(Theme.brown)
                .minimumScaleFactor(0.3)
                .frame(width: 550)
        }
    }
}

#Preview {
    PrepOnboardExplanationCard(description: "Move your iPad around and find Phoebe.")
}
