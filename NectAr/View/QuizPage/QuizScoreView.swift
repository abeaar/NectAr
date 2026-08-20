//
//  QuizScoreView.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 18/08/26.
//

import SwiftUI

struct QuizScoreView: View {
    var QuizViewModel: QuizViewModel
    
    let onBack: () -> Void
    let onRestart: () -> Void
    var isSuccess: Bool {
        QuizViewModel.score >= 80
    }
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            Image("Honeycomb")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    BackButton {
                        onBack()
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
            
            HStack {
                Image(isSuccess ? "leftBee" : "leftBeeCry")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .offset(y: -80)
                
                Spacer()
                
                Image(isSuccess ? "rightBee" : "rightBeeCry")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .offset(y: 120)
            }
            .padding(.horizontal, 120)
            

            VStack(spacing: 10) {
                Text("Your Score")
                    .font(Font.custom("Fredoka-Medium", size: 80, relativeTo: .title))
                    .foregroundStyle(Theme.brown)
                
                Text("\(QuizViewModel.score)")
                    .font(Font.custom("Fredoka-Bold", size: 300, relativeTo: .largeTitle))
                    .foregroundStyle(Theme.brown)
                
                if isSuccess {
                    Text("Good Job!")
                        .font(Font.custom("Fredoka-Medium", size: 50, relativeTo: .title))
                        .foregroundStyle(Theme.brown)
                } else {
                    Button(action: {
                        onRestart()
                    }) {
                        Text("Nice Try")
                            .font(Font.custom("Fredoka-Medium", size: 50, relativeTo: .title))
                            .foregroundStyle(Theme.brown)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                HStack(spacing: 32) {
                    Button(action: {
                        onBack()
                    }) {
                        Text("Back to Menu")
                            .font(Font.custom("SourGummy-Bold", size: 32, relativeTo: .title2))
                            .foregroundStyle(Theme.cream)
                            .frame(width: 250, height: 86)
                            .background(Theme.brown)
                            .cornerRadius(16)
                    }
                    Button(action: {
                        onRestart()
                    }) {
                        Text("Try Again")
                            .font(Font.custom("SourGummy-Bold", size: 32, relativeTo: .title2))
                            .foregroundStyle(Theme.brown)
                            .frame(width: 250, height: 86)
                            .background(Theme.yellow)
                            .cornerRadius(16)
                    }
                }
                .padding(.top, 32)
            }
            
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    QuizScoreView(
        QuizViewModel: QuizViewModel(),
        onBack: {},
        onRestart: {}
    )
}
