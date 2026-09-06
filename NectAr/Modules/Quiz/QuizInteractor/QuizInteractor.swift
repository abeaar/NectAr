//
//  QuizInteractor.swift
//  NectAr
//
//  Created by abr on 26/08/26.
//

import Foundation

struct QuizAnswerResult {
    let selectedAnswerIndex: Int
    let correctAnswerIndex: Int
    let isCorrect: Bool
}

struct QuizResult {
    let score: Int
    let isPassing: Bool
}

final class QuizInteractor {
    let questions: [Question]

    private(set) var currentQuestionIndex = 0
    private(set) var score = 0

    private let passingScore = 80

    init(questions: [Question] = QuizQuestionCatalog.all) {
        self.questions = questions
    }

    var currentQuestion: Question {
        questions[currentQuestionIndex]
    }

    var isLastQuestion: Bool {
        currentQuestionIndex == questions.count - 1
    }

    func answerQuestion(at index: Int) -> QuizAnswerResult {
        let question = currentQuestion
        let isCorrect = index == question.correctAnswerIndex

        if isCorrect {
            score += 100 / questions.count
        }

        return QuizAnswerResult(
            selectedAnswerIndex: index,
            correctAnswerIndex: question.correctAnswerIndex,
            isCorrect: isCorrect
        )
    }

    func moveToNextQuestion() {
        guard !isLastQuestion else { return }
        currentQuestionIndex += 1
    }

    func makeResult() -> QuizResult {
        QuizResult(score: score, isPassing: score >= passingScore)
    }

    func reset() {
        currentQuestionIndex = 0
        score = 0
    }
}
