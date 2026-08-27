//
//  QuizPresenter.swift
//  NectAr
//
//  Created by abr on 27/08/26.
//

import Foundation
import SwiftUI

@Observable
final class QuizPresenter {
    private let interactor: QuizInteractor

    var selectedAnswerIndex: Int?
    var isQuizFinished = false
    private(set) var result: QuizResult?

    init(interactor: QuizInteractor = QuizInteractor()) {
        self.interactor = interactor
    }

    var questions: [Question] { interactor.questions }
    var currentQuestionIndex: Int { interactor.currentQuestionIndex }
    var currentQuestion: Question { interactor.currentQuestion }
    var score: Int { interactor.score }

    func selectAnswer(index: Int) {
        guard selectedAnswerIndex == nil else { return }

        selectedAnswerIndex = index
        _ = interactor.answerQuestion(at: index)

        Task {
            try? await Task.sleep(for: .seconds(0.75))
            guard !Task.isCancelled else { return }

            await MainActor.run {
                if self.interactor.isLastQuestion {
                    self.result = self.interactor.makeResult()
                    self.isQuizFinished = true
                } else {
                    self.interactor.moveToNextQuestion()
                    self.selectedAnswerIndex = nil
                }
            }
        }
    }

    func resetQuiz() {
        interactor.reset()
        selectedAnswerIndex = nil
        result = nil
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
