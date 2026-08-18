//
//  ExpSimulationCard.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 14/08/26.
//

import Foundation

struct ExpSimulationCard: Identifiable {
    enum Source { case full, step(SimulationStepKind) }

    let id: String
    let source: Source
    let title: String
    let description: String
}