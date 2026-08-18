//
//  ARContainer.swift
//  NectAr
//
//
import SwiftUI
import RealityKit

struct ARContainerView: UIViewRepresentable {
    let arViewModel: ARViewModel<ARSessionManager>
    let placementViewModel: PlacementViewModel
    let mascotViewModel: MascotViewModel
    let simulationController: SimulationSceneController

    func makeUIView(context: Context) -> ARView {
        placementViewModel.attachARView(arViewModel.arView)
        mascotViewModel.attachARView(arViewModel.arView)
        simulationController.attachARView(arViewModel.arView)
        return arViewModel.arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
