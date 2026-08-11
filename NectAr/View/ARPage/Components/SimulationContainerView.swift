import SwiftUI
import RealityKit
import ARKit

struct SimulationContainerView: UIViewRepresentable {
    let viewModel: SimulationViewModel

    func makeUIView(context: Context) -> ARView {
        viewModel.attachARView()
        return viewModel.arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
