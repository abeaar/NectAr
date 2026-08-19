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

    let cards: [ExpSimulationCard]

    init() {
        let list: [ExpSimulationCard] = SimulationStepKind.allCases.map { step in
            .init(id: "step.\(step.title)", source: .step(step),
                  title: step.title, description: step.explanation)
        }
        self.cards = list
        self.activeCardID = list.first?.id
    }

    func toggleVisibility() {
        isListVisible.toggle()
    }

    func setActiveCard(id: String) {
        activeCardID = id
    }

    /// Returns the sidebar card id matching a simulation phase, or nil if there
    /// is no dedicated card for the phase.
    func cardID(forStep step: SimulationStepKind) -> String? {
        cards.first(where: { card in
            if case .step(let s) = card.source { return s == step }
            return false
        })?.id
    }
}