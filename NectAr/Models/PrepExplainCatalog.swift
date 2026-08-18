//
//  PrepExplainTextCatalog.swift
//  NectAr
//
//  Created by abr on 14/08/26.
//

import Foundation

enum PrepExplainCatalog {
    static let all: [PrepExplain] = [
        // Start, Phoebe introduction.
        PrepExplain(
            id: "1",
            description: "Move your iPad around And find Phoebe.",
            cardStyle: .explanationCard,
            hidesPlacementUI: true
        ),
        PrepExplain(
            id: "2",
            description: "You Found Phoebe!",
            cardStyle: .explanationCard,
            hidesPlacementUI: true
        ),
        PrepExplain(
            id: "3",
            description: "Hello, my name is Phoebe. I am your bee guide.",
            hidesPlacementUI: true,
            advance: PrepExplain.Advance(next: "4", duration: 5, canAdvanceNow: true)
        ),
        PrepExplain(
            id: "4",
            description: "Let me show you how this works.",
            hidesPlacementUI: true,
            advance: PrepExplain.Advance(next: "5", duration: 3, canAdvanceNow: true)
        ),
        PrepExplain(
            id: "5",
            description: "Do you want to skip the tutorial?",
            hidesPlacementUI: true
        ),

        // Tutorial sequence, shown when the user chooses not to skip. Router
        // stays excluded from the device list through all of it, only its own
        // dedicated step ("14") allows selecting it.
        PrepExplain(
            id: "6",
            description: "Please, pay attention.",
            locksPlacementUI: true,
            excludesRouterFromSelection: true,
            suppressedWhenSkipped: true,
            advance: PrepExplain.Advance(next: "7", duration: 2, canAdvanceNow: true)
        ),
        PrepExplain(
            id: "7",
            description: "First, find 2 devices and put them on a table.",
            locksPlacementUI: true,
            excludesRouterFromSelection: true,
            suppressedWhenSkipped: true,
            advance: PrepExplain.Advance(next: "8", duration: 30, canAdvanceNow: true)
        ),
        PrepExplain(
            id: "8",
            description: "Make sure the devices are far away from each other.",
            locksPlacementUI: true,
            excludesRouterFromSelection: true,
            suppressedWhenSkipped: true,
            advance: PrepExplain.Advance(next: "9", duration: 10, canAdvanceNow: true)
        ),
        PrepExplain(
            id: "9",
            description: "Click Device A, point the camera at your first device.",
            highlightTarget: .deviceSelector,
            usesSpotlightOverlay: true,
            excludesRouterFromSelection: true,
            suppressedWhenSkipped: true,
            advance: PrepExplain.Advance(next: "10", duration: nil, canAdvanceNow: true)
        ),
        PrepExplain(
            id: "10",
            description: "Click this action button to mark your devices.",
            highlightTarget: .actionButton,
            usesSpotlightOverlay: true,
            excludesRouterFromSelection: true,
            suppressedWhenSkipped: true,
            advance: PrepExplain.Advance(next: "11", duration: nil, canAdvanceNow: true)
        ),
        PrepExplain(
            id: "11",
            description: "Do the same for your second device.",
            excludesRouterFromSelection: true,
            suppressedWhenSkipped: true
        ),
        PrepExplain(
            id: "12",
            description: "Your devices connect you to the Internet.",
            excludesRouterFromSelection: true,
            suppressedWhenSkipped: true,
            advance: PrepExplain.Advance(next: "13", duration: 5, canAdvanceNow: true)
        ),
        PrepExplain(
            id: "13",
            description: "Make sure all the devices are ready!",
            excludesRouterFromSelection: true,
            suppressedWhenSkipped: true,
            advance: PrepExplain.Advance(next: "14", duration: 5, canAdvanceNow: true)
        ),
        PrepExplain(
            id: "14",
            description: "Now choose the Router.",
            highlightTarget: .routerOnly,
            usesSpotlightOverlay: true,
            suppressedWhenSkipped: true,
            advance: PrepExplain.Advance(next: "15", duration: nil, canAdvanceNow: true)
        ),
        PrepExplain(
            id: "15",
            description: "Lets look up to find a wall, then place the router up high.",
            highlightTarget: .actionButton,
            suppressedWhenSkipped: true
        ),
        PrepExplain(
            id: "16",
            description: "This is a router. It connects your devices to the Internet.",
            suppressedWhenSkipped: true,
            advance: PrepExplain.Advance(next: "17", duration: 5, canAdvanceNow: true)
        ),
        PrepExplain(
            id: "17",
            description: "You're all set. Let's start the simulation!",
            highlightTarget: .actionButton,
            suppressedWhenSkipped: true
        ),

        // Skip branch's terminal message, same copy as "17", no highlight.
        PrepExplain(
            id: "18",
            description: "You're all set. Let's start the simulation!"
        ),

        // Unused, kept pending a decision.
        PrepExplain(
            id: "19",
            description: "Move your Ipad around and find The  Bee"
        )
    ]
}
