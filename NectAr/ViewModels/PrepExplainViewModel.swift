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

    var currentText: String? { service.currentText }

    func step(to id: PrepExplain.ID) {
        service.step(to: id)
    }

    func step(forStory storyID: Story.ID) {
        service.step(forStory: storyID)
    }

    func reset() {
        service.reset()
    }
}
