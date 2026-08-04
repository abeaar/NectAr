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
    var isDebugModeOn: Bool = false
    let controller: PlacementSceneController

    func makeUIView(context: Context) -> ARView {
        arView.debugOptions = isDebugModeOn ? [.showAnchorGeometry] : []
        controller.arView = arView
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        uiView.debugOptions = isDebugModeOn ? [.showAnchorGeometry] : []
    }
}
