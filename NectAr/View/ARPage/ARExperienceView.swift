//
//  ARExperienceView.swift
//  NectAr
//

import SwiftUI

struct ARExperienceView: View {
    let onExitToMenu: () -> Void

    @State private var arViewModel: ARViewModel<ARSessionManager>
    @State private var placementViewModel = PlacementViewModel()
    @State private var mascotViewModel = MascotViewModel()
    @State private var simulationController = SimulationSceneController()
    @State private var phase: ARPhase = .preparation

    init(onExitToMenu: @escaping () -> Void) {
        self.onExitToMenu = onExitToMenu
        _arViewModel = State(initialValue: ARViewModel())
    }

    var body: some View {
        ZStack {
            ARContainerView(
                arViewModel: arViewModel,
                placementViewModel: placementViewModel,
                mascotViewModel: mascotViewModel,
                simulationController: simulationController
            )
            .ignoresSafeArea()

            switch phase {
            case .preparation:
                PreparationView(
                    arViewModel: arViewModel,
                    placementViewModel: placementViewModel,
                    mascotViewModel: mascotViewModel,
                    onBack: onExitToMenu
                ) { topology in
                    phase = .simulation(topology)
                }
            case .simulation(let topology):
                SimulationView(
                    simulationController: simulationController,
                    arViewModel: arViewModel,
                    placementViewModel: placementViewModel,
                    mascotViewModel: mascotViewModel,
                    topology: topology
                ) {
                    phase = .preparation
                }
            }
        }
    }
}
