//
//  ARExperienceView.swift
//  NectAr
//

import SwiftUI

struct ARExperienceView: View {
    let onExitToMenu: () -> Void

    @State private var arViewModel: ARViewModel<ARSessionManager>
    @State private var preparationViewModel: PreparationViewModel
    @State private var phase: ARPhase = .preparation

    init(onExitToMenu: @escaping () -> Void) {
        self.onExitToMenu = onExitToMenu

        let arViewModel = ARViewModel()
        let preparationViewModel = PreparationViewModel(
            arViewModel: arViewModel,
            placementController: PreparationSceneController(),
            mascotController: MascotOnboardingController()
        )
        _arViewModel = State(initialValue: arViewModel)
        _preparationViewModel = State(initialValue: preparationViewModel)
    }

    var body: some View {
        switch phase {
        case .preparation:
            PreparationView(
                viewModel: preparationViewModel,
                onBack: onExitToMenu
            ) { topology in
                phase = .simulation(topology)
            }
        case .simulation(let topology):
            SimulationView(arViewModel: arViewModel, topology: topology) {
                phase = .preparation
            }
        }
    }
}
