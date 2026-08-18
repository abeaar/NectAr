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
    /// Terminal step of the guided tutorial, its Play-button highlight is
    /// suppressed once the user has already reached simulation once.
    private static let finalStepID = "17"
    /// Terminal step of the skip branch.
    private static let skipCompleteID = "18"

    private(set) var currentEntry: PrepExplain?
    private(set) var isTutorialSkipped = false
    /// True once the user answers the skip-tutorial prompt, either way. Until
    /// then the placement UI stays hidden and locked regardless of a step's
    /// own flags, covering the gaps between intro beats (e.g. while the bee
    /// flies through the camera) where `currentEntry` is momentarily nil.
    private(set) var hasAnsweredSkipPrompt = false
    /// True once the router-placement beat has been reached, gating when the
    /// all-set step is allowed to appear reactively, see `refreshFinalStep`.
    private(set) var isEligibleForFinalStep = false
    /// True once the user has entered simulation at least once this AR
    /// session, suppressing the final step's Play-button highlight on a
    /// later return to preparation, see `currentHighlightTarget`.
    private(set) var hasVisitedSimulation = false
    private var autoAdvanceTask: Task<Void, Never>?

    var currentText: String? { currentEntry?.description }
    var currentCardStyle: PrepExplainCardStyle? { currentEntry?.cardStyle }

    var currentHighlightTarget: PrepExplainHighlightTarget? {
        guard let target = currentEntry?.highlightTarget else { return nil }
        if currentEntry?.id == Self.finalStepID, hasVisitedSimulation {
            return nil
        }
        return target
    }

    var hidesPlacementUI: Bool {
        guard hasAnsweredSkipPrompt else { return true }
        return currentEntry?.hidesPlacementUI ?? false
    }
    var locksPlacementUI: Bool {
        guard hasAnsweredSkipPrompt else { return true }
        return currentEntry?.locksPlacementUI ?? false
    }
    var usesSpotlightOverlay: Bool { currentEntry?.usesSpotlightOverlay ?? false }
    var excludesRouterFromSelection: Bool { currentEntry?.excludesRouterFromSelection ?? false }

    /// True during the two windows with no narration of its own: after the
    /// tutorial's router-placement beat, or after skipping, both before full
    /// completion. Only here is the tracking-status fallback allowed to show,
    /// so it never competes with an actively playing narration step.
    var isInFreeWindow: Bool {
        guard currentEntry == nil else { return false }
        return isTutorialSkipped || isEligibleForFinalStep
    }

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
    /// unknown, already current, or belongs to the guided placement steps while
    /// the tutorial has been skipped.
    func step(to id: PrepExplain.ID) {
        guard let entry = PrepExplainCatalog.all.first(where: { $0.id == id }) else { return }
        guard !(isTutorialSkipped && entry.suppressedWhenSkipped) else { return }
        guard currentEntry?.id != id else { return }

        clearCurrentEntry()
        currentEntry = entry

        if let advance = entry.advance, let duration = advance.duration {
            autoAdvanceTask = Task { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                guard !Task.isCancelled else { return }
                self?.step(to: advance.next)
            }
        }
    }

    /// Drives narration from the menu carousel. Called by `MenuView` whenever
    /// the centered story changes.
    func step(forStory storyID: Story.ID) {
        guard let prepID = Self.menuStoryMap[storyID] else { return }
        step(to: prepID)
    }

    /// Cuts a pending auto-advance short, called when the user taps the card
    /// instead of waiting out the step's default duration, or when a step has
    /// no timer at all but still allows a tap to skip ahead of its condition.
    /// No-op for a step that doesn't allow it.
    func advanceNow() {
        guard let advance = currentEntry?.advance, advance.canAdvanceNow else { return }
        step(to: advance.next)
    }

    /// Marks the router-placement beat reached, called once when the tutorial
    /// steps into "16". Only from that point on does `refreshFinalStep` treat
    /// full completion as reason to show the all-set step, so placing the
    /// router out of order earlier in the tutorial doesn't jump ahead.
    func markEligibleForFinalStep() {
        isEligibleForFinalStep = true
    }

    /// Shows or hides the tutorial's final step in step with live completion
    /// state, called after every placement and every undo. Only acts while
    /// idle or already on that step, so it never interrupts a step actively
    /// playing.
    func refreshFinalStep(isComplete: Bool) {
        guard isEligibleForFinalStep else { return }
        guard currentEntry == nil || currentEntry?.id == Self.finalStepID else { return }

        if isComplete {
            step(to: Self.finalStepID)
        } else if currentEntry?.id == Self.finalStepID {
            clear()
        }
    }

    /// Shows or hides the skip branch's terminal message in step with live
    /// completion state, called after every placement and every undo.
    func refreshSkipComplete(isComplete: Bool) {
        guard isTutorialSkipped else { return }

        if isComplete {
            step(to: Self.skipCompleteID)
        } else if currentEntry?.id == Self.skipCompleteID {
            clear()
        }
    }

    /// User chose to skip the guided placement narration from the skip-tutorial
    /// prompt, only the distance-gate hint and the final all-set line still show.
    func skipTutorial() {
        hasAnsweredSkipPrompt = true
        isTutorialSkipped = true
        clearCurrentEntry()
    }

    /// User chose not to skip, entering the guided tutorial at "6".
    func continueTutorial() {
        hasAnsweredSkipPrompt = true
        step(to: "6")
    }

    /// User reached simulation, called once from `ARExperienceView` the
    /// moment preparation hands off to it.
    func markSimulationVisited() {
        hasVisitedSimulation = true
    }

    /// Clears the current beat without touching skip state, used between
    /// sequential narration beats that don't need a full teardown.
    func clear() {
        clearCurrentEntry()
    }

    /// Full teardown for leaving the AR view entirely.
    func reset() {
        clearCurrentEntry()
        isTutorialSkipped = false
        hasAnsweredSkipPrompt = false
        isEligibleForFinalStep = false
        hasVisitedSimulation = false
    }

    private func clearCurrentEntry() {
        autoAdvanceTask?.cancel()
        autoAdvanceTask = nil
        currentEntry = nil
    }
}
