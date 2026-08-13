//
//  PlacementViewModel.swift
//  NectAr
//

import Foundation
import RealityKit

@Observable
final class PlacementViewModel {
    private let controller: PlacementController

    init(controller: PlacementController = PlacementController()) {
        self.controller = controller
    }

    var placedKinds: Set<DeviceKind> { controller.placedKinds }
    var placedTransforms: [DeviceKind: simd_float4x4] { controller.placedTransforms }
    var canUndo: Bool { controller.canUndo }
    var isComplete: Bool { controller.isComplete }
    var isPreviewActive: Bool { controller.isPreviewActive }
    var hintText: String? { controller.placementDistanceHint }

    func attachARView(_ arView: ARView) {
        controller.arView = arView
    }

    func selectDevice(_ kind: DeviceKind) {
        controller.selectDevice(kind)
    }

    func confirmPlacement() {
        controller.confirmPlacement()
    }

    func undoLastPlacement() {
        controller.undoLastPlacement()
    }

    func finishPlacement() {
        controller.finishPlacement()
    }

    func setRangeSphereVisible(_ visible: Bool) {
        controller.setRangeSphereVisible(visible)
    }

    func tearDown() {
        controller.tearDown()
    }
}
