//
//  TestLoad3D.swift
//  NectAr
//
//  Created by abr on 12/08/26.
//

import Foundation
import SwiftUI
import RealityKit
import ARKit
import Iphone
import MacBook

/// Mockup AR: tap ke permukaan nyata untuk menaruh model, lalu:
/// - 1 jari drag  -> rotate (sumbu Y)
/// - 2 jari drag  -> reposisi (raycast ulang ke plane)
/// - pinch        -> zoom in/out (scale)
/// Butuh device fisik — kamera passthrough & plane detection tidak jalan di simulator.
struct TestLoaderView: View {
    @State private var tappedEntityName: String = "None"
    @State private var loadError: String?
    @State private var hasPlacedModel = false

    var body: some View {
        ZStack(alignment: .top) {
            ARTestContainer(
                tappedEntityName: $tappedEntityName,
                loadError: $loadError,
                hasPlacedModel: $hasPlacedModel
            )
            .ignoresSafeArea()

            VStack(spacing: 4) {
                Text("Component: \(tappedEntityName)")
                    .font(.headline)

                if let loadError {
                    Text("Gagal memuat model: \(loadError)")
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                if !hasPlacedModel {
                    Text("Arahkan kamera ke permukaan datar, lalu tap untuk menaruh model")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("1 jari: rotate  •  2 jari drag: pindah  •  pinch: zoom")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding(.top)
        }
    }
}

private struct ARTestContainer: UIViewRepresentable {
    @Binding var tappedEntityName: String
    @Binding var loadError: String?
    @Binding var hasPlacedModel: Bool

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        arView.session.run(config)
        arView.debugOptions = [.showFeaturePoints]

        context.coordinator.arView = arView
        context.coordinator.setupGestures(on: arView)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(tappedEntityName: $tappedEntityName, loadError: $loadError, hasPlacedModel: $hasPlacedModel)
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        weak var arView: ARView?
        private var placedAnchor: AnchorEntity?
        private var placedEntity: ModelEntity?

        private var initialScale: Float = 1.0
        private var currentScale: Float = 1.0
        private let minScale: Float = 0.2
        private let maxScale: Float = 3.0

        @Binding var tappedEntityName: String
        @Binding var loadError: String?
        @Binding var hasPlacedModel: Bool

        init(tappedEntityName: Binding<String>, loadError: Binding<String?>, hasPlacedModel: Binding<Bool>) {
            _tappedEntityName = tappedEntityName
            _loadError = loadError
            _hasPlacedModel = hasPlacedModel
        }

        func setupGestures(on arView: ARView) {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))

            // 1 jari drag -> rotate. maximumNumberOfTouches dikunci ke 1 supaya
            // begitu jari kedua ditambahkan, gesture ini otomatis batal (bukan lanjut jadi 2 jari).
            let rotatePan = UIPanGestureRecognizer(target: self, action: #selector(handleRotatePan(_:)))
            rotatePan.minimumNumberOfTouches = 1
            rotatePan.maximumNumberOfTouches = 1

            // Tap hanya dianggap tap kalau rotatePan gagal (tidak ada gerakan) —
            // ini yang membedakan "tap untuk taruh model" dari "drag 1 jari untuk rotate".
            tap.require(toFail: rotatePan)

            // 2 jari drag -> reposisi (raycast ulang ke plane nyata tiap event).
            let dragPan = UIPanGestureRecognizer(target: self, action: #selector(handleDragPan(_:)))
            dragPan.minimumNumberOfTouches = 2
            dragPan.maximumNumberOfTouches = 2

            // Pinch -> zoom in/out (scale).
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))

            for recognizer in [tap, rotatePan, dragPan, pinch] {
                recognizer.delegate = self
                arView.addGestureRecognizer(recognizer)
            }
        }

        // Izinkan drag 2 jari dan pinch berjalan bersamaan (keduanya sama-sama pakai 2 jari).
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            (gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer) ||
            (gestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer)
        }

        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView, placedEntity == nil else { return }
            let location = sender.location(in: arView)

            guard let result = arView.raycast(
                from: location,
                allowing: .estimatedPlane,
                alignment: .horizontal
            ).first else { return }

            Task { @MainActor in
                await placeModel(at: result.worldTransform, in: arView)
            }
        }

        @objc func handleRotatePan(_ sender: UIPanGestureRecognizer) {
            guard let arView, let placedEntity else { return }
            guard sender.state == .changed else { return }

            let translation = sender.translation(in: arView)
            let rotateSensitivity: Float = 0.01
            let deltaAngle = Float(translation.x) * rotateSensitivity

            placedEntity.orientation *= simd_quatf(angle: deltaAngle, axis: [0, 1, 0])
            sender.setTranslation(.zero, in: arView)
        }

        @objc func handleDragPan(_ sender: UIPanGestureRecognizer) {
            guard let arView, let placedAnchor else { return }
            guard sender.state == .changed else { return }

            let location = sender.location(in: arView)
            guard let result = arView.raycast(
                from: location,
                allowing: .estimatedPlane,
                alignment: .horizontal
            ).first else { return }

            placedAnchor.transform.matrix = result.worldTransform
        }

        @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
            guard let placedEntity else { return }

            switch sender.state {
            case .changed:
                let scale = Float(sender.scale) * initialScale
                currentScale = min(max(scale, minScale), maxScale)
                placedEntity.scale = [currentScale, currentScale, currentScale]
            case .ended, .cancelled:
                initialScale = currentScale
            default:
                break
            }
        }

        @MainActor
        private func placeModel(at worldTransform: simd_float4x4, in arView: ARView) async {
            do {
                // "Iphone.usda" bukan ".usdz" mentah — usda ini me-reference usdz
                // tapi sudah dibungkus xformOp:scale untuk menormalisasi skala aslinya.
                let loaded = try await Entity(named: "MacBook.usda", in: macBookBundle)

                let container = ModelEntity()
                container.name = loaded.name.isEmpty ? "MacBook" : loaded.name
                container.addChild(loaded)

                let bounds = loaded.visualBounds(relativeTo: loaded)
                container.components.set(
                    CollisionComponent(shapes: [
                        .generateBox(size: bounds.extents).offsetBy(translation: bounds.center)
                    ])
                )
                container.components.set(InputTargetComponent())
                container.components.set(HoverEffectComponent())
                container.components.set(GroundingShadowComponent(castsShadow: true))

                let anchor = AnchorEntity(world: worldTransform)
                anchor.addChild(container)
                arView.scene.addAnchor(anchor)

                placedAnchor = anchor
                placedEntity = container
                initialScale = 1.0
                currentScale = 1.0
                hasPlacedModel = true
                tappedEntityName = container.name
            } catch {
                loadError = error.localizedDescription
                print("Gagal memuat aset: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    TestLoaderView()
}
