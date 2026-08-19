//
//  QuizView.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 18/08/26.
//

import SwiftUI

struct QuizView: View {
    @State private var QuizviewModel = QuizViewModel()
    
    @State private var showAlert = false
    
    let onBack: () -> Void
    let columns = [
        GridItem(.fixed(525), spacing: 10),
        GridItem(.fixed(525), spacing: 10)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack (alignment: .top){
                Theme.background
                    .ignoresSafeArea()
                
                Image("Honeycomb")
                    .resizable()
                    .ignoresSafeArea()
                
                HStack {
                    BackButton {
                        showAlert = true
                    }
                    .padding()
                    Spacer()
                }
                
                VStack(spacing: 30) {
                    ZStack {
                        Text("Question \(QuizviewModel.currentQuestionIndex + 1)")
                            .font(Font.custom("Fredoka-Bold", size: 92, relativeTo: .largeTitle))
                            .foregroundStyle(Theme.brown)
                        
                        Image("QuizHeader")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 725)
                    }
                    .padding()
                    
                    Spacer()
                    
                    ZStack {
                        Image("QuizBox")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 1100)
                        
                        Text(QuizviewModel.currentQuestion.text)
                            .font(Font.custom("Fredoka-Medium", size: 34, relativeTo: .title))
                            .foregroundStyle(Theme.brown)
                            .frame(width: 1000, height: 130)
                            .minimumScaleFactor(0.4)
                        
                    }
                    
                    ZStack {
                        Rectangle()
                            .frame(width: 1085, height: 330)
                            .foregroundStyle(Theme.yellow)
                            .cornerRadius(26)
                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 0)
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(0..<4, id: \.self) { index in
                                Button(action: {
                                    QuizviewModel.selectAnswer(index: index)
                                }) {
                                    Text(QuizviewModel.currentQuestion.options[index])
                                        .font(Font.custom("Fredoka-Medium", size: 24, relativeTo: .title))
                                        .foregroundStyle(Theme.brown)
                                        .padding(16)
                                        .frame(width: 510, height: 135)
                                        .minimumScaleFactor(0.4)
                                        .background(QuizviewModel.buttonColor(for: index))
                                        .cornerRadius(16)
                                }
                                .disabled(QuizviewModel.selectedAnswerIndex != nil)
                            }
                        }
                    }
                    Spacer()
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $QuizviewModel.isQuizFinished) {
                QuizScoreView(
                    QuizViewModel: QuizviewModel,
                    onBack: {
                        onBack()
                    },
                    onRestart: {
                        QuizviewModel.resetQuiz()
                    }
                )
            }
        }
        .overlay {
            if showAlert {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    QuizAlertCard(
                        onExitToMenu: {
                            onBack()
                        },
                        onCancel: {
                            showAlert = false
                        }
                    )
                }
                .transition(.opacity)
                .animation(.easeInOut, value: showAlert)
            }
        }
    }
}

#Preview {
    QuizView(
        onBack: {}
    )
}
