//
//  SimulationViewModel.swift
//  NectAr
//

import Foundation
import RealityKit

@Observable
final class SimulationViewModel {
    private let arViewModel: ARViewModel<ARSessionManager>
    private let simulationController: SimulationSceneController
    private let sceneControllers: [ARSceneDriven]

    init(
        arViewModel: ARViewModel<ARSessionManager>,
        simulationController: SimulationSceneController
    ) {
        self.arViewModel = arViewModel
        self.simulationController = simulationController
        self.sceneControllers = [simulationController]
    }

    var arView: ARView { arViewModel.arView }

    var hintText: String? {
        simulationController.deadzoneHint ?? simulationController.currentLegHint
    }

    // Wiring the ARView into every scene controller is infrastructure, not a user
    // action — same reasoning as PreparationViewModel.attachARView(). SimulationContainerView
    // (UIViewRepresentable) is the only caller.
    func attachARView() {
        for controller in sceneControllers {
            controller.arView = arViewModel.arView
        }
    }

    func startAnimating(topology: PlacedTopology) {
        simulationController.startAnimating(topology: topology)
    }

    func exit(then onExit: () -> Void) {
        simulationController.stopAnimating()
        onExit()
    }
}
