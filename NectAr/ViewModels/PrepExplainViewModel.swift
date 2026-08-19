//
//  PrepExplainVM.swift
//  NectAr
//
//  Created by abr on 15/08/26.
//

import Foundation

@Observable
final class PrepExplainViewModel {
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
    var canAdvanceNow: Bool { service.canAdvanceNow }
    var isInFreeWindow: Bool { service.isInFreeWindow }

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

    func reset() {
        service.reset()
    }
}
