//
//  PrepExplainService.swift
//  NectAr
//
//  Created by abr on 15/08/26.
//

import Foundation

/// Single source of truth for the narration string shown in `HintTextView`.
/// Owned by `ARExperienceView`, attached to controllers that want to advance
/// the text (currently `MascotOnboardingController` and `PlacementController`),
/// and read by `PrepExplainVM` so component views stay passive.
@Observable
final class PrepExplainService {
    private(set) var currentText: String?

    /// Maps menu story ids to the PrepExplain id that should describe the
    /// "curtain" phase as the user swipes through the carousel, so entering
    /// AR is already mid-narration.
    static let menuStoryMap: [Story.ID: PrepExplain.ID] = [
        "wifi": "1",
        "streaming": "6",
        "iot": "9",
        "game": "8",
        "browsing": "10"
    ]

    /// Advances narration to the catalog entry with `id`. No-op when the id is
    /// unknown or already current, so multiple subscribers can call freely.
    func step(to id: PrepExplain.ID) {
        guard let entry = PrepExplainCatalog.all.first(where: { $0.id == id }) else { return }
        guard currentText != entry.description else { return }
        currentText = entry.description
    }

    /// Drives narration from the menu carousel. Called by `MenuView` whenever
    /// the centered story changes.
    func step(forStory storyID: Story.ID) {
        guard let prepID = Self.menuStoryMap[storyID] else { return }
        step(to: prepID)
    }

    func reset() {
        currentText = nil
    }
}
