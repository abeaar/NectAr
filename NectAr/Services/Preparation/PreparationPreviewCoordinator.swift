//
//  PreparationPreviewCoordinator.swift
//  NectAr
//

import Foundation
import RealityKit
import ARKit

@Observable
final class PreparationPreviewCoordinator {
    private static let previewableKinds: Set<DeviceKind> = [.router]
    private static let previewSmoothingFactor: Float = 0.25

    weak var arView: ARView?
    private var previewAnchor: AnchorEntity?
    private var previewEntity: Entity?
    private var loadTask: Task<Void, Never>?

    static func isPreviewable(_ kind: DeviceKind) -> Bool {
        previewableKinds.contains(kind)
    }

    func show(_ kind: DeviceKind) {
        teardown()
        loadTask = Task {
            await load(kind)
        }
    }

    func teardown() {
        loadTask?.cancel()
        loadTask = nil

        if let arView, let previewAnchor {
            AnchoredEntityPlacer.remove(previewAnchor, from: arView.scene)
        }
        previewAnchor = nil
        previewEntity = nil
    }

    func update(isPlaced: Bool) {
        guard let arView, let previewEntity else { return }

        guard !isPlaced else {
            teardown()
            return
        }

        let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        guard let hit = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any).first else {
            return
        }

        movePreviewEntity(previewEntity, to: hit.worldTransform)
        previewEntity.isEnabled = true
    }

    private func load(_ kind: DeviceKind) async {
        guard let arView else { return }

        do {
            let entity = try await DeviceEntityLoader.load(kind, includeRangeSphere: false)
            try Task.checkCancellation()

            PreparationPreviewStyler.applyGhostMaterial(to: entity)
            entity.isEnabled = false

            let anchor = AnchorEntity(world: matrix_identity_float4x4)
            anchor.addChild(entity)
            arView.scene.addAnchor(anchor)

            previewAnchor = anchor
            previewEntity = entity
        } catch {
        }
    }

    private func movePreviewEntity(_ entity: Entity, to matrix: simd_float4x4) {
        let target = Transform(matrix: matrix)
        var transform = entity.transform
        transform.translation = simd_mix(transform.translation, target.translation, SIMD3(repeating: Self.previewSmoothingFactor))
        transform.rotation = simd_slerp(transform.rotation, target.rotation, Self.previewSmoothingFactor)
        entity.transform = transform
    }
}
