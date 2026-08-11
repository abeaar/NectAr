//
//  PreparationViewModel.swift
//  NectAr
//

import Foundation
import RealityKit

@Observable
final class PreparationViewModel {
    private let arViewModel: ARViewModel<ARSessionManager>
    private let placementController: PreparationSceneController
    private let mascotController: MascotOnboardingController
    private let sceneControllers: [ARSceneDriven]

    init(
        arViewModel: ARViewModel<ARSessionManager>,
        placementController: PreparationSceneController,
        mascotController: MascotOnboardingController
    ) {
        self.arViewModel = arViewModel
        self.placementController = placementController
        self.mascotController = mascotController
        self.sceneControllers = [placementController, mascotController]
    }

    var arView: ARView { arViewModel.arView }

    // MARK: - Single-source state (plain forwards)

    var placedKinds: Set<DeviceKind> { placementController.placedKinds }
    var canUndo: Bool { placementController.canUndo }
    var isComplete: Bool { placementController.isComplete }
    var isPreviewActive: Bool { placementController.isPreviewActive }

    // MARK: - Merged state

    var hintText: String {
        mascotController.mascotHint ?? placementController.placementDistanceHint ?? arViewModel.hintText
    }

    // MARK: - Actions

    func start() {
        arViewModel.start()
    }

    func attachARView() {
        for controller in sceneControllers {
            controller.arView = arViewModel.arView
        }
    }

    func selectDevice(_ kind: DeviceKind) {
        guard !mascotController.isActive else { return }
        placementController.send(.selectDevice(kind))
    }

    func undoLastPlacement() {
        placementController.send(.undoLastPlacement)
    }

    func tapActionButton(onComplete: (PlacedTopology) -> Void) {
        if mascotController.isActive {
            mascotController.attemptFind()
        } else if placementController.isComplete {
            placementController.send(.finishPlacement)
            onComplete(PlacedTopology(transforms: placementController.placedTransforms))
        } else {
            placementController.send(.confirmPlacement)
        }
    }

    func exitToMenu(then onBack: () -> Void) {
        placementController.send(.exitToMenu)
        mascotController.tearDown()
        arViewModel.pause()
        onBack()
    }
}
