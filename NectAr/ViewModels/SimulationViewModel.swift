//
//  SimulationViewModel.swift
//  NectAr
//

import Foundation
import RealityKit

@Observable
final class SimulationViewModel {
    private let arViewModel: ARViewModel<ARSessionManager>
    private let mascotViewModel: MascotViewModel
    private let simulationController: SimulationSceneController
    private let sceneControllers: [ARSceneDriven]

    init(
        arViewModel: ARViewModel<ARSessionManager>,
        mascotViewModel: MascotViewModel,
        simulationController: SimulationSceneController
    ) {
        self.arViewModel = arViewModel
        self.mascotViewModel = mascotViewModel
        self.simulationController = simulationController
        self.sceneControllers = [simulationController]
    }

    var arView: ARView { arViewModel.arView }

    var hintText: String? {
        simulationController.deadzoneHint ?? simulationController.currentLegHint
    }

    func attachARView() {
        for controller in sceneControllers {
            controller.arView = arViewModel.arView
        }
        // Bee stays alive across preparation → simulation, so it needs to be re-attached
        // to the (shared) ARView here too — see MascotViewModel.attachARView.
        mascotViewModel.attachARView(arViewModel.arView)
    }

    func startAnimating(topology: PlacedTopology) {
        simulationController.startAnimating(topology: topology)
    }

    func exit(then onExit: () -> Void) {
        simulationController.stopAnimating()
        onExit()
    }
}
