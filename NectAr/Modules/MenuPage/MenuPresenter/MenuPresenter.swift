//
//  MenuPresenter.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 28/08/26.
//

import Foundation
import SwiftUI

@Observable
class MenuPresenter {
    private let interactor: MenuInteractor
    private let router: MenuRouter
//    private let sound = SoundViewModel()
    
    var stories: [Story] = []
    var activeStoryID: Story.ID?
    var expandedStoryID: Story.ID?
    var isActive: Bool!
    var isExpanded: Bool {
        expandedStoryID != nil
    }

    init(interactor: MenuInteractor = MenuInteractor(quizUnlockService: QuizUnlockService()), router: MenuRouter = MenuRouter()) {
            self.interactor = interactor
            self.router = router
        }

    func loadContent() {
        stories = interactor.fetchStories()
        if activeStoryID == nil {
            activeStoryID = stories.first?.id
        }
    }

    func isQuizUnlocked(for storyID: String) -> Bool {
        return interactor.isQuizUnlocked(for: storyID)
    }

    func selectStory(id: Story.ID) {
        guard activeStoryID != id else { return }
//        sound.play("CardBubble.mp3")
        activeStoryID = id
        expandedStoryID = nil
    }
    
    func expandCard(id: Story.ID) {
//        sound.play("bubble.mp3")
        expandedStoryID = id
    }

    func collapseCard() {
        expandedStoryID = nil
    }

    func playStory(id: Story.ID) {
//        sound.play("bubble.mp3")
        router.navStory(id: id)
    }

    func openQuiz() {
        router.navQuiz()
    }
}
