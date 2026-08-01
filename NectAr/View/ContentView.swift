//
//  ContentView.swift
//  NectAr
//
//  Created by abr on 01/08/26.
//

import SwiftUI

struct ContentView: View {
    @State private var currentPhase: AppPhase = .placement
    @State private var arViewModel = ARViewModel()

    var body: some View {
        switch currentPhase {
        case .story:
            Text("Story phase - TODO")
        case .placement:
            PlacementView(arViewModel: arViewModel)
        case .simulation:
            Text("Simulation phase - TODO")
        }
    }
}

