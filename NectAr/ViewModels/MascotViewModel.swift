//
//  MascotViewModel.swift
//  NectAr
//

import Foundation
import RealityKit

@Observable
final class MascotViewModel {
    private let controller: MascotOnboardingController

    init(controller: MascotOnboardingController = MascotOnboardingController()) {
        self.controller = controller
    }

    var isActive: Bool { controller.isActive }

    func attachARView(_ arView: ARView) {
        controller.arView = arView
    }

    func attachPrepExplainService(_ service: PrepExplainService) {
        controller.attachPrepExplainService(service)
    }

    func handleTap(at location: CGPoint, in arView: ARView) {
        controller.handleTap(at: location, in: arView)
    }

    func tearDown() {
        controller.tearDown()
    }
}
