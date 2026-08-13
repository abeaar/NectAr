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
import ARWolrd

/// Mockup AR: tap ke permukaan nyata untuk menaruh model (load biasa, tanpa gesture rotate/drag/pinch).
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
                    Text("Model sudah ditaruh")
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

    final class Coordinator: NSObject {
        weak var arView: ARView?
        private var placedEntity: ModelEntity?

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
            arView.addGestureRecognizer(tap)
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

        @MainActor
        private func placeModel(at worldTransform: simd_float4x4, in arView: ARView) async {
            do {
                let scene = try await Entity(named: "Scene.usda", in: aRWolrdBundle)

                guard let iphone = scene.findEntity(named: "Iphone"),
                      let bee = scene.findEntity(named: "Bee") else {
                    loadError = "Entity Iphone/Bee tidak ditemukan di Scene.usda"
                    return
                }

                let container = ModelEntity()
                container.name = "Assets"
                container.addChild(iphone)
                container.addChild(bee)

                let anchor = AnchorEntity(world: worldTransform)
                anchor.addChild(container)
                arView.scene.addAnchor(anchor)

                placedEntity = container
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
