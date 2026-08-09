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
            PreparationView(arViewModel: arViewModel, placementController: placementController) {
                currentPhase = .simulation
            }
        case .simulation:
            Text("Simulation phase - TODO")
        }
    }
}
#Preview {
    ContentView()
}
