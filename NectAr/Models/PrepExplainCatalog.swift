//
//  PrepExplainTextCatalog.swift
//  NectAr
//
//  Created by abr on 14/08/26.
//

import Foundation

enum PrepExplainCatalog {
    static let all: [PrepExplain] = [
        PrepExplain(
            id: "1",
            description: "Move your iPad around and find Phoebe.",
            cardStyle: .prepOnboardCard,
            hidesPlacementUI: true
        ),
        PrepExplain(
            id: "2",
            description: "Yay! You found Phoebe.",
            cardStyle: .prepOnboardCard,
            hidesPlacementUI: true
        ),
        PrepExplain(
            id: "3",
            description: "Hello again, my name is Phoebe. I am your bee guide.",
            locksPlacementUI: true,
            advance: PrepExplain.Advance(next: "4", duration: 5, canAdvanceNow: true)
        ),
        PrepExplain(
            id: "4",
            description: "Click the device on the left side of the screen.",
            highlightTarget: .deviceSelector,
            usesSpotlightOverlay: true
        ),
        PrepExplain(
            id: "5",
            description: "Tap the action button to put the device in place.",
            highlightTarget: .actionButton
        ),
        PrepExplain(
            id: "6",
            description: "Make sure all the devices are placed and ready.",
            advance: PrepExplain.Advance(next: nil, duration: 5, canAdvanceNow: true)
        ),
        PrepExplain(
            id: "7",
            description: "You're all set!",
            advance: PrepExplain.Advance(next: nil, duration: 5, canAdvanceNow: true)
        )
    ]
}
