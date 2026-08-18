//
//  ContentView.swift
//  NectAr
//
//  Created by abr on 01/08/26.
//

import SwiftUI

struct ContentView: View {
    @State private var currentPhase: AppPhase = .menu
    @State private var prepExplainService = PrepExplainService()

    var body: some View {
        switch currentPhase {
        case .menu:
            MenuView { storyID in
                prepExplainService.step(forStory: storyID)
                currentPhase = .ar(storyID)
            }
        case .ar(let storyID):
            ARExperienceView(storyID: storyID, prepExplainService: prepExplainService) {
                currentPhase = .menu
            }
        }
    }
}
#Preview {
    ContentView()
}
