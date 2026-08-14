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
    var hintText: String? { controller.mascotHint }

    func attachARView(_ arView: ARView) {
        controller.arView = arView
    }

    func tearDown() {
        controller.tearDown()
    }
}
