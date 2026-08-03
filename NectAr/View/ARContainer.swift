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
    //for debug
    var isDebugModeOn: Bool = false

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        arView.session = session
        //    arView.debugOptions = [.showAnchorGeometry] For prod
        arView.debugOptions = isDebugModeOn ? [.showAnchorGeometry] : []
        return arView
    }
    
    // func updateUIView(_ uiView: ARView, context: Context) {} for prod 
    func updateUIView(_ uiView: ARView, context: Context) {
        uiView.debugOptions = isDebugModeOn ? [.showAnchorGeometry] : []
    }
}
