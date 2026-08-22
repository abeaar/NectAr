//
//  ExpSimulationCard.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 14/08/26.
//

import Foundation

struct ExpSimulationCard: Identifiable {
    enum TerminalReason { case router, target }
    enum Source { case fullSimulation, step(SimulationStepKind), failure(SimulationFailureReason), wallObstruction(leg: SimulationStepKind), unableToSend(TerminalReason) }

    let id: String
    let source: Source
    let title: String
    let description: String
}