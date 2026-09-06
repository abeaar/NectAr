//
//  MenuInteractor.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 28/08/26.
//

import Foundation

class MenuInteractor {
    private let quizUnlockService: QuizUnlockService

    init(quizUnlockService: QuizUnlockService) {
        self.quizUnlockService = quizUnlockService
    }

    func fetchStories() -> [Story] {
        return StoryCatalog.all
    }

    func isQuizUnlocked(for storyID: String) -> Bool {
        return quizUnlockService.isUnlocked(storyID)
    }
}
