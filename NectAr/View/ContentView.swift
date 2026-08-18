//
//  ContentView.swift
//  NectAr
//
//  Created by abr on 01/08/26.
//

import SwiftUI

struct ContentView: View {
    @State private var currentPhase: AppPhase = .ar

    var body: some View {
        switch currentPhase {
        case .menu:
            MenuView {
                currentPhase = .ar
            }
        case .ar:
            ARExperienceView {
                currentPhase = .menu
            }
        }
    }
}
#Preview {
    ContentView()
}
