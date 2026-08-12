import SwiftUI

struct SimulationView: View {
    let topology: PlacedTopology
    let onExit: () -> Void

    @State private var viewModel: SimulationViewModel

    init(
        arViewModel: ARViewModel<ARSessionManager>,
        mascotViewModel: MascotViewModel,
        topology: PlacedTopology,
        onExit: @escaping () -> Void
    ) {
        self.topology = topology
        self.onExit = onExit
        _viewModel = State(initialValue: SimulationViewModel(
            arViewModel: arViewModel,
            mascotViewModel: mascotViewModel,
            simulationController: SimulationSceneController()
        ))
    }

    var body: some View {
        ZStack(alignment: .top) {
            SimulationContainerView(viewModel: viewModel)
                .ignoresSafeArea()

            if let hint = viewModel.hintText {
                HintTextView(hintText: hint)
            }

            HStack {
                Spacer()
                Button {
                    viewModel.exit(then: onExit)
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
            viewModel.startAnimating(topology: topology)
        }
    }
}
