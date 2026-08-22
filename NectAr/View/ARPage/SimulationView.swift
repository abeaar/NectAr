import SwiftUI

struct SimulationView: View {
    let simulationController: SimulationSceneController
    
    let arViewModel: ARViewModel<ARSessionManager>
    
    let placementViewModel: PlacementViewModel
    
    let mascotViewModel: MascotViewModel
    
    let topology: PlacedTopology
    let onExit: () -> Void
    let onQuiz: () -> Void

    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                SidebarSimulation(controller: simulationController)
                Spacer()
                StopButton {
                    simulationController.stopAnimating()
                    simulationController.showStandaloneMascot()
                    onExit()
                }
                .padding(.trailing)
            }

            if simulationController.isQuizPromptActive {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                SimulationQuizPromptCard(
                    onAccept: {
                        simulationController.stopAnimating()
                        simulationController.showStandaloneMascot()
                        onQuiz()
                    },
                    onDecline: {
                        simulationController.declineSecondLoop()
                    }
                )
                .transition(.opacity)
                .animation(.easeInOut, value: simulationController.isQuizPromptActive)
            }
        }
        .onAppear {
            simulationController.startAnimating(topology: topology)
        }
    }
}

#Preview {
    SimulationView(
        simulationController: SimulationSceneController(),
        arViewModel: ARViewModel(sessionManager: ARSessionManager()),
        placementViewModel: PlacementViewModel(),
        mascotViewModel: MascotViewModel(),
        topology: PlacedTopology(transforms: [:]),
        onExit: {},
        onQuiz: {}
    )
}
