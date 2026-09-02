//
//  MenuRouter.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 02/09/26.
//

import SwiftUI

class MenuRouter {
    private var onStart: ((Story.ID) -> Void)?
    private var onQuiz: (() -> Void)?
    
    func navStory(id: Story.ID) {
        onStart?(id)
    }
    
    func navQuiz() {
        onQuiz?()
    }
    
    static func createModule( quizUnlockService: QuizUnlockService, onStart: @escaping (Story.ID) -> Void, onQuiz: @escaping () -> Void) -> some View {
            let router = MenuRouter()
            router.onStart = onStart
            router.onQuiz = onQuiz

            let interactor = MenuInteractor(quizUnlockService: quizUnlockService)
            let presenter = MenuPresenter(interactor: interactor)
            let view = MenuView()

            return view
        }
}
