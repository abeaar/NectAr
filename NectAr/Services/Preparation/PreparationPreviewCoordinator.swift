//
//  PreparationPreviewCoordinator.swift
//  NectAr
//

import Foundation
import RealityKit
import ARKit
import UIKit

@Observable
final class PreparationPreviewCoordinator {
    private static let previewableKinds: Set<DeviceKind> = Set(DeviceKind.allCases)
    private static let previewSmoothingFactor: Float = 0.25

    weak var arView: ARView?
    private var previewAnchor: AnchorEntity?
    private var previewEntity: Entity?
    private var previewKind: DeviceKind?
    private var originalMaterials: PreparationPreviewStyler.OriginalMaterials?
    private var loadTask: Task<Void, Never>?
    private var isShowingInRangeGhost = false

    static func isPreviewable(_ kind: DeviceKind) -> Bool {
        previewableKinds.contains(kind)
    }

    /// Hands off the already-loaded, already-decorated preview entity for `kind` so it
    /// can be reused as the real placement instead of loading the same asset again.
    /// Returns nil if there's no ready preview for that kind yet, still loading or a
    /// different kind is being previewed, in which case the caller falls back to a
    /// fresh load.
    func claimEntityForPlacement(_ kind: DeviceKind) -> Entity? {
        guard previewKind == kind, let entity = previewEntity, let anchor = previewAnchor else { return nil }

        loadTask?.cancel()
        loadTask = nil

        if let originalMaterials {
            PreparationPreviewStyler.restoreOriginalMaterial(originalMaterials)
        }
        anchor.removeChild(entity)
        if let arView, anchor.children.isEmpty {
            arView.scene.removeAnchor(anchor)
        }
        entity.isEnabled = true

        previewAnchor = nil
        previewEntity = nil
        previewKind = nil
        self.originalMaterials = nil
        return entity
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
        previewKind = nil
        originalMaterials = nil
        isShowingInRangeGhost = false
    }

    func update(isPlaced: Bool, isBlocked: Bool) {
        guard let arView, let previewEntity, let previewKind else { return }

            guard !isPlaced else {
                teardown()
                return
            }

            let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        guard let hit = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any).first else {
                previewEntity.isEnabled = false
                return
            }

        let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        if let hit = arView.raycast(from: center, allowing: .estimatedPlane, alignment: previewKind.placementAlignment).first {
            movePreviewEntity(previewEntity, to: hit.worldTransform)
            previewEntity.isEnabled = true
            setGhostColor(isInRange: !isBlocked)
        } else if let wrongSurfaceHit = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any).first {
            // A surface exists here, just not one this device can go on.
            movePreviewEntity(previewEntity, to: wrongSurfaceHit.worldTransform)
            previewEntity.isEnabled = true
            setGhostColor(isInRange: false)
        } else {
            previewEntity.isEnabled = false
        }
    }

    private func setGhostColor(isInRange: Bool) {
        guard let previewEntity else { return }
        guard isInRange != isShowingInRangeGhost else { return }
        isShowingInRangeGhost = isInRange
        PreparationPreviewStyler.updateGhostColor(on: previewEntity, isInRange: isInRange)
    }

    private func load(_ kind: DeviceKind) async {
        guard let arView else { return }

        do {
            let entity = try await DeviceEntityLoader.load(kind)
            try Task.checkCancellation()

            DeviceEntityDecorator.decorate(entity, for: kind, includeRangeSphere: false)
            let original = PreparationPreviewStyler.applyGhostMaterial(to: entity)
            entity.isEnabled = false

            let anchor = AnchorEntity(world: matrix_identity_float4x4)
            anchor.addChild(entity)
            arView.scene.addAnchor(anchor)

            previewAnchor = anchor
            previewEntity = entity
            previewKind = kind
            originalMaterials = original
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
 
