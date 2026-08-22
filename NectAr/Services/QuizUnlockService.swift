//
//  QuizUnlockService.swift
//  NectAr
//

import Foundation

/// Tracks which stories the user has reached a successful simulation on, gating
/// the menu's quiz button. In-memory only for now, so it resets every app launch.
@Observable
final class QuizUnlockService {
    private(set) var unlockedStoryIDs: Set<Story.ID> = []

    func markUnlocked(_ storyID: Story.ID) {
        unlockedStoryIDs.insert(storyID)
    }

    func isUnlocked(_ storyID: Story.ID) -> Bool {
        unlockedStoryIDs.contains(storyID)
    }
}
