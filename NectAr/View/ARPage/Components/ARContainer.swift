//
//  ARContainer.swift
//  NectAr
//
//
import SwiftUI
import RealityKit
import UIKit

struct ARContainerView: UIViewRepresentable {
    let arViewModel: ARViewModel<ARSessionManager>
    let placementViewModel: PlacementViewModel
    let mascotViewModel: MascotViewModel

    func makeUIView(context: Context) -> ARView {
        placementViewModel.attachARView(arViewModel.arView)
        mascotViewModel.attachARView(arViewModel.arView)

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arViewModel.arView.addGestureRecognizer(tapGesture)

        return arViewModel.arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(mascotViewModel: mascotViewModel)
    }

    /// Forwards taps on the AR surface to the mascot controller, so tapping the
    /// bee finds it immediately instead of relying on the hover dwell alone.
    final class Coordinator: NSObject {
        let mascotViewModel: MascotViewModel

        init(mascotViewModel: MascotViewModel) {
            self.mascotViewModel = mascotViewModel
        }

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let arView = recognizer.view as? ARView else { return }
            mascotViewModel.handleTap(at: recognizer.location(in: arView), in: arView)
        }
    }
}
