//
//  ContentView.swift
//  NectAr
//
//  Created by abr on 01/08/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false
    @State private var currentPhase: AppPhase = .splash
    @State private var prepExplainService = PrepExplainService()

    var body: some View {
        switch currentPhase {
        case .splash:
            SplashScreenView(onFinished: {
                currentPhase = hasOnboarded ? .menu : .onboarding
            })
        case .onboarding:
            OnBoardingView(onContinue: {
                hasOnboarded = true
                currentPhase = .menu
            })
        case .menu:
            MenuView(
                onStart: { storyID in
                    prepExplainService.step(forStory: storyID)
                    currentPhase = .ar(storyID)
                },
                onQuiz: {
                    currentPhase = .quiz
                }
            )
        case .ar(let storyID):
            ARExperienceView(storyID: storyID, prepExplainService: prepExplainService) {
                currentPhase = .menu
            }
        case .quiz:
            QuizView(onBack: {
                currentPhase = .menu
            })
        }
    }
}
#Preview {
    ContentView()
}
