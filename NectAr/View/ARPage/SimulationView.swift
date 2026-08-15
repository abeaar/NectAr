import SwiftUI

struct SimulationView: View {
    let arViewModel: ARViewModel<ARSessionManager>
    let topology: PlacedTopology
    let onExit: () -> Void
    @State private var simulationController = SimulationSceneController()
    @State private var isSidebarOpen = true

    var body: some View {
        ZStack(alignment: .topLeading) {
            SimulationContainerView(arView: arViewModel.arView, controller: simulationController)
                .ignoresSafeArea()

            HStack {
                Spacer()
                Button {
                    simulationController.stopAnimating()
                    onExit()
                } label: {
                    Image("StopButton2")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)

            // Fixed at the back button's usual position, since simulation has no
            // back button of its own, the sidebar opens directly below it.
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    isSidebarOpen.toggle()
                } label: {
                    Image(systemName: isSidebarOpen ? "list.bullet.rectangle.fill" : "list.bullet.rectangle")
                        .padding()
                        .background(.black.opacity(0.6))
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                }
                .padding(.leading, 24)
                .padding(.top, 16)

                if isSidebarOpen {
                    SimulationSidebarView(controller: simulationController)
                        .padding(.top, 12)
                }
            }
            .ignoresSafeArea(edges: .leading)
        }
        .onAppear {
            simulationController.startAnimating(topology: topology)
        }
    }
}

#Preview {
    SimulationView(
        arViewModel: ARViewModel(sessionManager: ARSessionManager()),
        topology: PlacedTopology(transforms: [:]),
        onExit: {}
    )
}
