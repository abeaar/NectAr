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
            // ini masih belum fix, silahkan klau mau di otak atik
        case .story:
            StoryView { story in
                currentPhase = .placement
            }
        case .placement:
            ARCameraView(arViewModel: arViewModel)
        case .simulation:
            Text("Simulation phase - TODO")
        }
    }
}
#Preview {
    ContentView()
}
