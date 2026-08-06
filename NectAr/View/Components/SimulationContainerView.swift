import SwiftUI
import RealityKit
import ARKit

struct SimulationContainerView: UIViewRepresentable {
    let arView: ARView
    let controller: SimulationSceneController

    func makeUIView(context: Context) -> ARView {
        controller.arView = arView
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
