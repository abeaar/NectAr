//
//  ARExperienceView.swift
//  NectAr
//

import SwiftUI

struct ARExperienceView: View {
    /// Not yet consumed beyond seeding `prepExplainVM`'s narration, groundwork for
    /// a future story-driven device catalog.
    let storyID: Story.ID
    let onExitToMenu: () -> Void

    @State private var arViewModel: ARViewModel<ARSessionManager>
    @State private var placementViewModel = PlacementViewModel()
    @State private var mascotViewModel = MascotViewModel()
    @State private var prepExplainVM: PrepExplainViewModel
    @State private var simulationController = SimulationSceneController()
    @State private var phase: ARPhase = .preparation

    init(storyID: Story.ID, prepExplainService: PrepExplainService, onExitToMenu: @escaping () -> Void) {
        self.storyID = storyID
        self.onExitToMenu = onExitToMenu
        _arViewModel = State(initialValue: ARViewModel())
        _prepExplainVM = State(initialValue: PrepExplainViewModel(service: prepExplainService))
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
                    prepExplainVM: prepExplainVM,
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
