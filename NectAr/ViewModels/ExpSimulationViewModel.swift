//
//  ExpSimulationViewModel.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 14/08/26.
//

import SwiftUI

@Observable
class ExpSimulationViewModel {

    var isListVisible: Bool = true
    var activeCardID: UUID? = nil
    var cards: [ExpSimulation] = []
    
    init() {
        // placeholder
        cards = [
            ExpSimulation(title: "Title", description: "Lorem ipsum dolor sit amet, elit, sed do eiusmod tempor incididunt ut. Woakwoakw awokawok"),
            ExpSimulation(title: "Lorem Ipsum", description: "Lorem ipsum Dolor si amet aowkoakwoawk abe diarak phoebe wokwo"),
            ExpSimulation(title: "Moew Meow mEOW", description: "orem ipsum dolor sit amet, elit, sed do eiusmod tempor incididunt ut. Woakwoakw awokawok"),
            ExpSimulation(title: "Awwrrrrrrr", description: "Lorem ipsum Dolor si amet aowkoakwoawk abe diarak phoebe wokwo wow keren"),
            ExpSimulation(title: "Saya ngantuk", description: "orem ipsum dolor sit amet, elit, sed do eiusmod tempor incididunt ut. Woakwoakw awokwk wow keren")
        ]
        
        activeCardID = cards.first?.id
    }
    
    func toggleVisibility() {
        isListVisible.toggle()
    }
    
    func setActiveCard(id: UUID) {
        activeCardID = id
    }
}
