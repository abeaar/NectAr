//
//  ExpSimulationViewModel.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 14/08/26.
//

import Foundation

@Observable
final class ExpSimulationViewModel {

    var isListVisible: Bool = true
    var activeCardID: String?

    static let failureCardID = "failure"

    private static let unableToSendToRouterCard = ExpSimulationCard(
        id: "terminal.router",
        source: .unableToSend(.router),
        title: "Unable to Send To Router",
        description: "The packet cannot travel to your router."
    )
    private static let unableToSendToTargetCard = ExpSimulationCard(
        id: "terminal.target",
        source: .unableToSend(.target),
        title: "Unable to Send To Target",
        description: "The router cannot find the address of Target in its range."
    )
    private static let fullSimulationCard = ExpSimulationCard(
        id: "full-simulation",
        source: .fullSimulation,
        title: "Full Simulation",
        description: "Watch the full journey! See how your text message travels from your device, through the router, all the way to the other device and back."
    )

    init() {
        activeCardID = stepCard(.introduction).id
    }

    /// Builds the situational card sequence for the sidebar. With no failure, this is
    /// the full six-step walkthrough with a wall card spliced in right after any leg
    /// it was discovered on, "Introduction" replaced by "Full Simulation" once the
    /// second loop has started. With a failure, the sequence truncates to the prefix
    /// that actually played, followed by the failure card and, for a single
    /// out-of-range device, the matching "Unable to Send" card.
    func cards(failureReason: SimulationFailureReason?, sendToRouterObstructed: Bool, sendToTargetObstructed: Bool, isSecondLoop: Bool) -> [ExpSimulationCard] {
        guard let failureReason else {
            var result: [ExpSimulationCard] = []
            for step in SimulationStepKind.allCases {
                if step == .introduction, isSecondLoop {
                    result.append(Self.fullSimulationCard)
                    continue
                }
                result.append(stepCard(step))
                if step == .sendToRouter && sendToRouterObstructed {
                    result.append(wallCard(for: .sendToRouter))
                }
                if step == .sendToTarget && sendToTargetObstructed {
                    result.append(wallCard(for: .sendToTarget))
                }
            }
            return result
        }

        var result = failureReason.reachablePhases.map(stepCard) + [failureCard(failureReason)]
        if let terminal = terminalCard(for: failureReason) {
            result.append(terminal)
        }
        return result
    }

    /// The trailing "Unable to Send" card id for a failure, nil when that failure has
    /// no reachable leg to have failed sending from (both out of range, router off).
    func terminalCardID(for failureReason: SimulationFailureReason) -> String? {
        terminalCard(for: failureReason)?.id
    }

    func toggleVisibility() {
        isListVisible.toggle()
    }

    func setActiveCard(id: String) {
        activeCardID = id
    }

    func cardID(forStep step: SimulationStepKind) -> String {
        stepCard(step).id
    }

    func wallCardID(for leg: SimulationStepKind) -> String {
        wallCard(for: leg).id
    }

    /// Resolves the controller's `SimulationCardID` into the sidebar's actual card
    /// id, nil for `.terminal` when the current failure has no trailing card.
    func cardID(for card: SimulationCardID, failureReason: SimulationFailureReason?) -> String? {
        switch card {
        case .step(let step): return cardID(forStep: step)
        case .wall(let leg): return wallCardID(for: leg)
        case .failure: return Self.failureCardID
        case .terminal:
            guard let failureReason else { return nil }
            return terminalCardID(for: failureReason)
        case .fullSimulation: return Self.fullSimulationCard.id
        }
    }

    /// What tapping `card` should play, nil for cards that are informational only
    /// (the failure and terminal cards, which don't have a re-playable animation).
    func playbackSelection(for card: ExpSimulationCard) -> SimulationPlaybackSelection? {
        switch card.source {
        case .fullSimulation: return .fullPreview
        case .step(let step): return .step(step)
        case .wallObstruction(let leg): return .wall(leg)
        case .failure, .unableToSend: return nil
        }
    }

    private func stepCard(_ step: SimulationStepKind) -> ExpSimulationCard {
        .init(id: "step.\(step.title)", source: .step(step), title: step.title, description: step.explanation)
    }

    private func failureCard(_ reason: SimulationFailureReason) -> ExpSimulationCard {
        .init(id: Self.failureCardID, source: .failure(reason), title: reason.title, description: reason.description)
    }

    private func wallCard(for leg: SimulationStepKind) -> ExpSimulationCard {
        .init(id: "wall.\(leg.title)", source: .wallObstruction(leg: leg),
              title: "Signal Slowed by a Wall!",
              description: "WiFi signals get a little weaker passing through walls. The message will still arrive, just a bit slower.")
    }

    private func terminalCard(for failureReason: SimulationFailureReason) -> ExpSimulationCard? {
        switch failureReason {
        case .deviceOutOfRange(let kind) where kind == .deviceA:
            return Self.unableToSendToRouterCard
        case .deviceOutOfRange:
            return Self.unableToSendToTargetCard
        case .bothOutOfRange, .routerOff:
            return nil
        }
    }
}
