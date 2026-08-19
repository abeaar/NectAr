import SwiftUI

struct SimulationView: View {
    let simulationController: SimulationSceneController
    
    let arViewModel: ARViewModel<ARSessionManager>
    
    let placementViewModel: PlacementViewModel
    
    let mascotViewModel: MascotViewModel
    
    let topology: PlacedTopology
    let onExit: () -> Void

    var body: some View {
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
        onExit: {}
    )
}
