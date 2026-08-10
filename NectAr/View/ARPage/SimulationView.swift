import SwiftUI

struct SimulationView: View {
    let arViewModel: ARViewModel<ARSessionManager>
    let topology: PlacedTopology
    let onExit: () -> Void
    @State private var simulationController = SimulationSceneController()

    var body: some View {
        ZStack(alignment: .top) {
            SimulationContainerView(arView: arViewModel.arView, controller: simulationController)
                .ignoresSafeArea()

            if let hint = simulationController.deadzoneHint ?? simulationController.currentLegHint {
                HintTextView(hintText: hint)
            }

            HStack {
                Spacer()
                Button {
                    simulationController.stopAnimating()
                    onExit()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .padding()
                        .background(.black.opacity(0.6))
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                }
                .padding(.trailing, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        }
        .onAppear {
            simulationController.startAnimating(topology: topology)
        }
    }
}
