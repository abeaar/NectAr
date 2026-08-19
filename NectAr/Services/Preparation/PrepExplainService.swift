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
/// and read by `PrepExplainViewModel` so component views stay passive.
@Observable
final class PrepExplainService {
    /// Terminal step, shown once every device is placed.
    private static let finalStepID = "7"
    /// The one-time reminder shown right after the first device is placed.
    private static let pastIntroStepID = "6"
    /// Phoebe's guide intro, the first step that shows the placement UI.
    private static let guideIntroStepID = "3"

    private(set) var currentEntry: PrepExplain?
    /// True until the guide intro is first reached, forcing the placement UI
    /// hidden through the whole bee-hunt span including its nil gaps, e.g.
    /// while `OpacityComponent` fades the bee through the camera, not just
    /// while a `hidesPlacementUI` step happens to be current.
    private var isBeforeGuideIntro = true
    /// True once the sequence has passed the one-time step 6 reminder, the
    /// point after which only silent stretches and the completion message
    /// remain, see `isInFreeWindow`.
    private(set) var isPastIntro = false
    /// Guards `refreshFinalStep` from re-showing the terminal step every time
    /// it self-clears while completion is still true.
    private var hasShownFinalStep = false
    private var autoAdvanceTask: Task<Void, Never>?

    var currentText: String? { currentEntry?.description }
    var currentCardStyle: PrepExplainCardStyle? { currentEntry?.cardStyle }
    var currentHighlightTarget: PrepExplainHighlightTarget? { currentEntry?.highlightTarget }
    var hidesPlacementUI: Bool {
        guard !isBeforeGuideIntro else { return true }
        return currentEntry?.hidesPlacementUI ?? false
    }
    var locksPlacementUI: Bool { currentEntry?.locksPlacementUI ?? false }
    var usesSpotlightOverlay: Bool { currentEntry?.usesSpotlightOverlay ?? false }
    var canAdvanceNow: Bool { currentEntry?.advance?.canAdvanceNow ?? false }

    /// True during the silent stretch after step 6's reminder, before all
    /// devices are placed. Only here is the distance-gate/tracking-status
    /// fallback allowed to show, so it never competes with an actively
    /// playing narration step.
    var isInFreeWindow: Bool { currentEntry == nil && isPastIntro }

    /// Maps menu story ids to the PrepExplain id that should describe the
    /// "curtain" phase as the user swipes through the carousel, so entering
    /// AR is already mid-narration. The bee hunt always plays regardless of
    /// story and overrides this the moment AR actually starts, so only the
    /// very first step is worth priming here.
    static let menuStoryMap: [Story.ID: PrepExplain.ID] = [
        "wifi": "1"
    ]

    /// Advances narration to the catalog entry with `id`. No-op when the id is
    /// unknown or already current.
    func step(to id: PrepExplain.ID) {
        guard let entry = PrepExplainCatalog.all.first(where: { $0.id == id }) else { return }
        guard currentEntry?.id != id else { return }

        if id == Self.guideIntroStepID {
            isBeforeGuideIntro = false
        }
        if id == Self.pastIntroStepID {
            isPastIntro = true
        }

        clearCurrentEntry()
        currentEntry = entry

        if let advance = entry.advance, let duration = advance.duration {
            autoAdvanceTask = Task { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                guard !Task.isCancelled else { return }
                self?.advanceOrClear(to: advance.next)
            }
        }
    }

    /// Drives narration from the menu carousel. Called by `MenuView` whenever
    /// the centered story changes.
    func step(forStory storyID: Story.ID) {
        guard let prepID = Self.menuStoryMap[storyID] else { return }
        step(to: prepID)
    }

    /// Cuts a pending auto-advance short, called when the user taps the
    /// screen instead of waiting out the step's default duration. No-op for a
    /// step that doesn't allow it.
    func advanceNow() {
        guard let advance = currentEntry?.advance, advance.canAdvanceNow else { return }
        advanceOrClear(to: advance.next)
    }

    /// Shows or hides the terminal step in step with live completion state,
    /// called after every placement and every undo. Only shows it once per
    /// completion, so it doesn't reappear every time it self-clears while
    /// still complete, and only while idle so it never interrupts step 6.
    func refreshFinalStep(isComplete: Bool) {
        guard isComplete else {
            hasShownFinalStep = false
            if currentEntry?.id == Self.finalStepID {
                clear()
            }
            return
        }

        guard !hasShownFinalStep, currentEntry == nil else { return }
        hasShownFinalStep = true
        step(to: Self.finalStepID)
    }

    /// Clears the current beat without touching sequence progress, used
    /// between sequential narration beats that don't need a full teardown.
    func clear() {
        clearCurrentEntry()
    }

    /// Full teardown for leaving the AR view entirely.
    func reset() {
        clearCurrentEntry()
        isBeforeGuideIntro = true
        isPastIntro = false
        hasShownFinalStep = false
    }

    private func advanceOrClear(to next: PrepExplain.ID?) {
        if let next {
            step(to: next)
        } else {
            clear()
        }
    }

    private func clearCurrentEntry() {
        autoAdvanceTask?.cancel()
        autoAdvanceTask = nil
        currentEntry = nil
    }
}
