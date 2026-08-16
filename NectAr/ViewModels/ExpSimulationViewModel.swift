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
        var list: [ExpSimulationCard] = [
            .init(id: "full", source: .full,
                  title: SimulationFullCard.default.title,
                  description: SimulationFullCard.default.explanation)
        ]
        list.append(contentsOf: SimulationStepKind.allCases.map { step in
            .init(id: "step.\(step.title)", source: .step(step),
                  title: step.title, description: step.explanation)
        })
        self.cards = list
        self.activeCardID = list.first?.id
    }

    func toggleVisibility() {
        isListVisible.toggle()
    }

    func setActiveCard(id: String) {
        activeCardID = id
    }

    func source(for id: String) -> ExpSimulationCard.Source? {
        cards.first(where: { $0.id == id })?.source
    }
}