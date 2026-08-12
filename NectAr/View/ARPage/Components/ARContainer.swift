//
//  ARContainer.swift
//  NectAr
//
//
import SwiftUI
import RealityKit
import ARKit

struct ARContainerView: UIViewRepresentable {
    let arViewModel: ARViewModel<ARSessionManager>
    let placementViewModel: PlacementViewModel
    let mascotViewModel: MascotViewModel

    func makeUIView(context: Context) -> ARView {
        placementViewModel.attachARView(arViewModel.arView)
        mascotViewModel.attachARView(arViewModel.arView)
        return arViewModel.arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
