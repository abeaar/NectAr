//
//  ContentView.swift
//  NectAr
//
//  Created by abr on 01/08/26.
//

import SwiftUI

struct ContentView: View {
    @State private var currentPhase: AppPhase = .menu

    var body: some View {
        switch currentPhase {
        case .menu:
            MenuView {
                currentPhase = .ar
            }
        case .ar:
            // Owns the ARView and its controllers, so switching back to .menu
            // deallocates the whole AR stack rather than parking it in memory.
            ARExperienceView {
                currentPhase = .menu
            }
        }
    }
}
#Preview {
    ContentView()
}
