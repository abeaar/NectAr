//
//  QuizModel.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 18/08/26.
//

import SwiftUI

// nnti i refactor lg
@Observable
class QuizViewModel {
    var questions: [Question] = QuizQuestionCatalog.all
    var currentQuestionIndex: Int = 0
    var score: Int = 0
    var selectedAnswerIndex: Int? = nil
    var isQuizFinished: Bool = false
    
    var currentQuestion: Question {
        questions[currentQuestionIndex]
    }
    
    func selectAnswer(index: Int) {
        guard selectedAnswerIndex == nil else { return }
        
        selectedAnswerIndex = index
        
        if index == currentQuestion.correctAnswerIndex {
            score += 100 / questions.count
        }
        
        Task {
            try? await Task.sleep(for: .seconds(0.75))
            await MainActor.run {
                moveToNextQuestion()
            }
        }
    }
    
    private func moveToNextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswerIndex = nil
        } else {
            isQuizFinished = true
        }
    }
    
    func resetQuiz() {
        currentQuestionIndex = 0
        score = 0
        selectedAnswerIndex = nil
        isQuizFinished = false
    }
    
    func buttonColor(for index: Int) -> Color {
        guard let selected = selectedAnswerIndex else {
            return Theme.cream2
        }
        
        if index == currentQuestion.correctAnswerIndex {
            return .green
        }
        
        if index == selected {
            return .red
        }

        return .white
    }
}
