import Foundation
import RealityKit
import ARKit
import Combine

/// Drives the preparation phase: raycasts from the screen center against detected
/// planes, and anchors the selected ``DeviceKind``'s entity at the hit point.
///
/// Holds `arView` weakly because it's injected by `ARContainerView`
/// (`UIViewRepresentable.makeUIView`), which owns the actual `ARView`'s lifetime.
@Observable
final class PlacementSceneController {
    /// Non-device kinds get the grey ghost preview, device markers are small enough
    /// that the crosshair already covers them and stay on the plain crosshair.
    private static let previewableKinds: Set<DeviceKind> = [.router]
    /// Fraction of the remaining distance/rotation closed each frame (0-1). Manual
    /// lerp/slerp rather than `Entity.move(to:duration:)`, since retargeting an
    /// in-flight move animation every frame during fast camera motion is a known
    /// source of RealityKit visibly glitching (entities flickering or ghosting).
    private static let previewSmoothingFactor: Float = 0.25
    /// Maximum camera-to-target distance placement is allowed at, in meters.
    private static let maxPlacementDistance: Float = 3.0

    var selectedDeviceKind: DeviceKind = .deviceA {
        didSet {
            guard oldValue != selectedDeviceKind else { return }
            teardownPreview()
            if Self.previewableKinds.contains(selectedDeviceKind) {
                Task { await setupPreview(for: selectedDeviceKind) }
            }
        }
    }
    private(set) var placedTransforms: [DeviceKind: simd_float4x4] = [:]
    weak var arView: ARView? {
        didSet {
            guard arView != nil, updateSubscription == nil else { return }
            subscribeToSceneUpdates()
        }
    }
    private var placedAnchors: [DeviceKind: AnchorEntity] = [:]
    private var placementOrder: [DeviceKind] = []

    private var updateSubscription: Cancellable?
    private var previewAnchor: AnchorEntity?
    private var previewEntity: Entity?

    /// Set while the crosshair is over a surface farther than `maxPlacementDistance`,
    /// used as the placement hint and to block `confirmPlacement()`.
    private(set) var placementDistanceHint: String?

    var placedKinds: Set<DeviceKind> {
        Set(placedTransforms.keys)
    }

    var isComplete: Bool {
        placedKinds.count == DeviceKind.allCases.count
    }

    /// True while the live asset preview is standing in for the plain crosshair.
    var isPreviewActive: Bool {
        Self.previewableKinds.contains(selectedDeviceKind) && !placedKinds.contains(selectedDeviceKind)
    }

    func canPlace(_ kind: DeviceKind) -> Bool {
        !placedKinds.contains(kind)
    }

    var canUndo: Bool {
        !placementOrder.isEmpty
    }

    func confirmPlacement() {
        guard let arView else {
            print("AR view not ready yet")
            return
        }

        let kind = selectedDeviceKind
        guard canPlace(kind) else {
            print("\(kind.label) has already been placed")
            return
        }
        guard placementDistanceHint == nil else {
            print("Too far to place \(kind.label), move closer")
            return
        }

        let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        let results = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any)

        guard let firstResult = results.first else {
            print("No surface found at crosshair")
            return
        }

        Task {
            do {
                let entity = try await DeviceEntityLoader.load(kind)
                let anchor = AnchoredEntityPlacer.place(entity, at: firstResult.worldTransform, in: arView.scene)
                placedAnchors[kind] = anchor
                placedTransforms[kind] = firstResult.worldTransform
                placementOrder.append(kind)
            } catch {
                print("Failed to load \(kind) entity: \(error)")
            }
        }
    }

    /// Toggled by the preparation-phase debug button, shows or hides the placed
    /// router's range sphere independent of its other attributes.
    func setRangeSphereVisible(_ visible: Bool) {
        guard let arView else { return }
        let query = EntityQuery(where: .has(RouterAttributesComponent.self))
        for entity in arView.scene.performQuery(query) {
            entity.components[RangeSphereVisibilityComponent.self]?.isVisible = visible
        }
    }

    func undoLastPlacement() {
        guard let arView, let lastKind = placementOrder.popLast() else { return }

        if let anchor = placedAnchors[lastKind] {
            AnchoredEntityPlacer.remove(anchor, from: arView.scene)
        }
        placedAnchors[lastKind] = nil
        placedTransforms[lastKind] = nil

        if lastKind == selectedDeviceKind, Self.previewableKinds.contains(lastKind) {
            Task { await setupPreview(for: lastKind) }
        }
    }

    /// Call before leaving the placement screen so the preview's per-frame
    /// raycasting doesn't keep running in the background.
    func stopPreview() {
        teardownPreview()
        updateSubscription?.cancel()
        updateSubscription = nil
    }

    /// Releases every spawned entity so nothing lingers in the AR scene once this
    /// controller itself goes away, for example when navigating back to a main page.
    deinit {
        updateSubscription?.cancel()
        guard let arView else { return }
        if let previewAnchor { AnchoredEntityPlacer.remove(previewAnchor, from: arView.scene) }
        for (_, anchor) in placedAnchors { AnchoredEntityPlacer.remove(anchor, from: arView.scene) }
    }

    // MARK: - Live placement preview

    private func subscribeToSceneUpdates() {
        guard let arView else { return }
        updateSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] _ in
            self?.updatePreview()
            self?.updateDistanceGate()
        }
    }

    /// Live per-frame distance check against whatever's currently under the
    /// crosshair, so the move-closer hint tracks the user's position in real time.
    private func updateDistanceGate() {
        guard let arView, !placedKinds.contains(selectedDeviceKind) else {
            placementDistanceHint = nil
            return
        }

        let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        guard let hit = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any).first else {
            placementDistanceHint = nil
            return
        }

        let hitPosition = Transform(matrix: hit.worldTransform).translation
        let distance = simd_distance(arView.cameraTransform.translation, hitPosition)
        placementDistanceHint = distance > Self.maxPlacementDistance ? "Move closer to place \(selectedDeviceKind.label)" : nil
    }

    private func setupPreview(for kind: DeviceKind) async {
        guard let arView else { return }

        do {
            let entity = try await DeviceEntityLoader.load(kind, includeRangeSphere: false)
            PlacementPreviewStyler.applyGhostMaterial(to: entity)
            entity.isEnabled = false

            let anchor = AnchorEntity(world: matrix_identity_float4x4)
            anchor.addChild(entity)
            arView.scene.addAnchor(anchor)

            previewAnchor = anchor
            previewEntity = entity
        } catch {
            print("Failed to load \(kind) preview: \(error)")
        }
    }

    private func teardownPreview() {
        if let arView, let anchor = previewAnchor {
            AnchoredEntityPlacer.remove(anchor, from: arView.scene)
        }
        previewAnchor = nil
        previewEntity = nil
    }

    /// The preview stays grey the whole time it's unplaced, and only moves on a
    /// fresh raycast hit — off-plane it freezes at its last placeable position.
    private func updatePreview() {
        guard let arView, let previewEntity else { return }

        guard !placedKinds.contains(selectedDeviceKind) else {
            teardownPreview()
            return
        }

        let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        guard let hit = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any).first else {
            return
        }

        movePreviewEntity(previewEntity, to: hit.worldTransform)
        previewEntity.isEnabled = true
    }

    /// Eases toward each new raycast result instead of snapping to it, since a raw
    /// per-frame raycast is noisy enough (estimated-plane refinement, camera jitter)
    /// to visibly shake the preview if applied directly. Only translation/rotation
    /// are blended, so the entity's own scale is untouched.
    private func movePreviewEntity(_ entity: Entity, to matrix: simd_float4x4) {
        let target = Transform(matrix: matrix)
        var transform = entity.transform
        transform.translation = simd_mix(transform.translation, target.translation, SIMD3(repeating: Self.previewSmoothingFactor))
        transform.rotation = simd_slerp(transform.rotation, target.rotation, Self.previewSmoothingFactor)
        entity.transform = transform
    }
}
