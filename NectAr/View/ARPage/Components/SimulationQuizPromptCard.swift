//
//  SimulationQuizPromptCard.swift
//  NectAr
//

import SwiftUI

/// Shown once, after the first successful full simulation completes, offering to
/// jump straight into the quiz or keep exploring the simulation instead.
struct SimulationQuizPromptCard: View {
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        ZStack {
            Image("AlertCard")

            VStack(spacing: 12) {
                Text("Quiz Time!")
                    .font(Font.custom("SourGummy-Bold", size: 34, relativeTo: .largeTitle))
                    .frame(width: 345)

                Text("Are you ready for the quiz?")
                    .font(Font.custom("Fredoka-Medium", size: 24, relativeTo: .title2))
                    .frame(width: 345)
                    .multilineTextAlignment(.center)

                HStack(spacing: 22) {
                    ButtonStyle(
                        action: onDecline,
                        backgroundColor: Theme.red,
                        textColor: Theme.cream2,
                        text: "No"
                    )

                    ButtonStyle(
                        action: onAccept,
                        backgroundColor: Theme.yellow,
                        textColor: Theme.brown,
                        text: "Yes"
                    )
                }
                .padding(.top, 18)
            }
        }
    }
}

#Preview {
    SimulationQuizPromptCard(onAccept: {}, onDecline: {})
}
