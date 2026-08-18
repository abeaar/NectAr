//
//  PrepExplainVM.swift
//  NectAr
//
//  Created by abr on 15/08/26.
//

import Foundation

@Observable
final class PrepExplainVM {
    let service: PrepExplainService

    init(service: PrepExplainService) {
        self.service = service
    }

    var currentStepID: PrepExplain.ID? { service.currentEntry?.id }
    var currentText: String? { service.currentText }
    var currentCardStyle: PrepExplainCardStyle? { service.currentCardStyle }
    var currentHighlightTarget: PrepExplainHighlightTarget? { service.currentHighlightTarget }
    var hidesPlacementUI: Bool { service.hidesPlacementUI }
    var locksPlacementUI: Bool { service.locksPlacementUI }
    var usesSpotlightOverlay: Bool { service.usesSpotlightOverlay }
    var excludesRouterFromSelection: Bool { service.excludesRouterFromSelection }
    var isInFreeWindow: Bool { service.isInFreeWindow }
    /// "5", the skip-tutorial prompt.
    var isShowingSkipPrompt: Bool { service.currentEntry?.id == "5" }

    func step(to id: PrepExplain.ID) {
        service.step(to: id)
    }

    func step(forStory storyID: Story.ID) {
        service.step(forStory: storyID)
    }

    func advanceNow() {
        service.advanceNow()
    }

    func refreshFinalStep(isComplete: Bool) {
        service.refreshFinalStep(isComplete: isComplete)
    }

    func chooseSkipTutorial() {
        service.skipTutorial()
    }

    func chooseContinueTutorial() {
        service.continueTutorial()
    }

    func markSimulationVisited() {
        service.markSimulationVisited()
    }

    func reset() {
        service.reset()
    }
}
