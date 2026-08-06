//
//  ContentView.swift
//  NectAr
//
//  Created by abr on 01/08/26.
//

import SwiftUI

struct ContentView: View {
    @State private var currentPhase: AppPhase = .preparation
    @State private var arViewModel = ARViewModel()
    @State private var placementController = PlacementSceneController()

    var body: some View {
        switch currentPhase {
        case .preparation:
            PreparationView(arViewModel: arViewModel, placementController: placementController) { placedTopology in
                currentPhase = .simulation(placedTopology)
            }
        case .simulation(let topology):
            SimulationView(arViewModel: arViewModel, topology: topology) {
                currentPhase = .preparation
            }
        }
    }
}
#Preview {
    ContentView()
}
