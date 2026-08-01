//
//  ARContainer.swift
//  NectAr
//
//  
import SwiftUI
import RealityKit
import ARKit

struct ARContainerView: UIViewRepresentable {
    let session: ARSession

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        arView.session = session
        arView.debugOptions = [.showAnchorGeometry]
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
