//
//  ARContainer.swift
//  NectAr
//
//
import SwiftUI
import RealityKit
import ARKit

struct ARContainerView: UIViewRepresentable {
    let viewModel: PreparationViewModel

    func makeUIView(context: Context) -> ARView {
        viewModel.attachARView()
        return viewModel.arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
