//
//  ARExperienceView.swift
//  NectAr
//

import SwiftUI

struct ARExperienceView: View {
    /// Seeds `prepExplainVM`'s narration and marks the story unlocked in
    /// `quizUnlockService` on a successful simulation. Otherwise not yet
    /// consumed, groundwork for a future story-driven device catalog.
    let storyID: Story.ID
    let quizUnlockService: QuizUnlockService
    let onExitToMenu: () -> Void
    let onQuiz: () -> Void

    @State private var arViewModel: ARViewModel<ARSessionManager>
    @State private var placementViewModel = PlacementViewModel()
    @State private var mascotViewModel = MascotViewModel()
    @State private var prepExplainVM: PrepExplainViewModel
    @State private var simulationController = SimulationSceneController()
    @State private var phase: ARPhase = .preparation

    init(storyID: Story.ID, prepExplainService: PrepExplainService, quizUnlockService: QuizUnlockService, onExitToMenu: @escaping () -> Void, onQuiz: @escaping () -> Void) {
        self.storyID = storyID
        self.quizUnlockService = quizUnlockService
        self.onExitToMenu = onExitToMenu
        self.onQuiz = onQuiz
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
            .onChange(of: simulationController.isQuizPromptActive) { _, isActive in
                guard isActive else { return }
                quizUnlockService.markUnlocked(storyID)
            }

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
                    topology: topology,
                    onExit: { phase = .preparation },
                    onQuiz: onQuiz
                )
            }
        }
    }
}
