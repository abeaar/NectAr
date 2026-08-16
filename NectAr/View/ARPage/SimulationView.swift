import SwiftUI

struct SimulationView: View {
    let simulationController: SimulationSceneController
    let arViewModel: ARViewModel<ARSessionManager>
    let placementViewModel: PlacementViewModel
    let mascotViewModel: MascotViewModel
    let topology: PlacedTopology
    let onExit: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack {
                Spacer()
                Button {
                    simulationController.stopAnimating()
                    placementViewModel.tearDown()
                    mascotViewModel.tearDown()
                    arViewModel.pause()
                    onExit()
                } label: {
                    Image("StopButton2")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)

            SimulationSidebarView(controller: simulationController)
                .ignoresSafeArea(edges: .leading)
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