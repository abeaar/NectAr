//
//  ARContainer.swift
//  NectAr
//
//
import SwiftUI
import RealityKit
import ARKit

struct ARContainerView: UIViewRepresentable {
    let arView: ARView
    let controller: PlacementSceneController
    let mascotController: MascotOnboardingController

    func makeUIView(context: Context) -> ARView {
        controller.arView = arView
        mascotController.arView = arView
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
