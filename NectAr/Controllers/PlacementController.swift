//
//  PlacementController.swift
//  NectAr
//

import Foundation
import RealityKit
import ARKit
import Combine
import UIKit

@Observable
final class PlacementController: ARSceneDriven {
    private let previewCoordinator = PreparationPreviewCoordinator()
    private let distanceGate = PreparationDistance()
    private var ledger = PreparationLedger()

    private var placementsInFlight: Set<DeviceKind> = []
    private var updateSubscription: Cancellable?
    private var isPreviewSuspended = false

    private(set) var selectedDeviceKind: DeviceKind = .deviceA

    weak var arView: ARView? {
        didSet {
            previewCoordinator.arView = arView
            distanceGate.arView = arView
            guard arView != nil, updateSubscription == nil else { return }
            subscribeToSceneUpdates()
        }
    }

    var placedTransforms: [DeviceKind: simd_float4x4] { ledger.transforms }
    var placedKinds: Set<DeviceKind> { ledger.kinds }
    var isComplete: Bool { placedKinds.count == DeviceKind.allCases.count }
    var canUndo: Bool { !ledger.isEmpty }
    var placementDistanceHint: String? { distanceGate.hint }

    var isPreviewActive: Bool {
        !isPreviewSuspended && PreparationPreviewCoordinator.isPreviewable(selectedDeviceKind) && !placedKinds.contains(selectedDeviceKind)
    }

    func canPlace(_ kind: DeviceKind) -> Bool {
        !placedKinds.contains(kind)
    }

    /// Suspends the ghost preview entirely, used while the bee-hunt sequence is
    /// active so the crosshair and a device ghost don't compete for the same view.
    func setPreviewSuspended(_ suspended: Bool) {
        guard isPreviewSuspended != suspended else { return }
        isPreviewSuspended = suspended

        if suspended {
            previewCoordinator.teardown()
        } else if PreparationPreviewCoordinator.isPreviewable(selectedDeviceKind), !placedKinds.contains(selectedDeviceKind) {
            previewCoordinator.show(selectedDeviceKind)
        }
    }

    /// Toggled by the preparation-phase debug button, shows or hides the placed
    /// router's range sphere independent of its other attributes.
    func setRangeSphereVisible(_ visible: Bool) {
        guard let arView else { return }
        let query = EntityQuery(where: .has(DeviceIdentityComponent.self))
        for entity in arView.scene.performQuery(query) {
            guard entity.components[DeviceIdentityComponent.self]?.kind == .router else { continue }
            entity.components[RangeSphereVisibilityComponent.self]?.isVisible = visible
        }
    }

    func selectDevice(_ kind: DeviceKind) {
        guard selectedDeviceKind != kind else { return }
        selectedDeviceKind = kind
        if PreparationPreviewCoordinator.isPreviewable(kind) {
            previewCoordinator.show(kind)
        } else {
            previewCoordinator.teardown()
        }
    }

    func confirmPlacement() {
        guard let arView else {
            print("AR view not ready yet")
            return
        }

        let kind = selectedDeviceKind
        guard canPlace(kind), !placementsInFlight.contains(kind) else {
            print("\(kind.label) has already been placed, or is being placed")
            return
        }
        guard placementDistanceHint == nil else {
            print("Too far to place \(kind.label), move closer")
            return
        }

        let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        guard let firstResult = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any).first else {
            print("No surface found at crosshair")
            return
        }

        placementsInFlight.insert(kind)
        Task {
            defer { placementsInFlight.remove(kind) }
            do {
                let entity: Entity
                if let claimed = previewCoordinator.claimEntityForPlacement(kind) {
                    // Reuse the already-loaded ghost preview instead of fetching the
                    // same asset from its bundle a second time.
                    entity = claimed
                    DeviceEntityDecorator.attachRangeSphereIfNeeded(to: entity, for: kind)
                } else {
                    entity = try await DeviceEntityLoader.load(kind)
                    DeviceEntityDecorator.decorate(entity, for: kind)
                }
                let anchor = AnchoredEntityPlacer.place(entity, at: firstResult.worldTransform, in: arView.scene)
                ledger.record(kind, transform: firstResult.worldTransform, anchor: anchor)
            } catch {
                print("Failed to load \(kind) entity: \(error)")
            }
        }
    }

    func undoLastPlacement() {
        guard let arView, let (lastKind, anchor) = ledger.removeLast() else { return }
        AnchoredEntityPlacer.remove(anchor, from: arView.scene)

        if lastKind == selectedDeviceKind, PreparationPreviewCoordinator.isPreviewable(lastKind) {
            previewCoordinator.show(lastKind)
        }
    }

    func finishPlacement() {
        stopPreview()
    }

    func tearDown() {
        stopPreview()

        let anchors = ledger.removeAll()
        if let arView {
            for anchor in anchors { AnchoredEntityPlacer.remove(anchor, from: arView.scene) }
        }

        placementsInFlight.removeAll()
        distanceGate.reset()
        selectedDeviceKind = .deviceA
    }

    private func stopPreview() {
        previewCoordinator.teardown()
        updateSubscription?.cancel()
        updateSubscription = nil
    }

    private func subscribeToSceneUpdates() {
        guard let arView else { return }
        updateSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] _ in
            guard let self else { return }
            let isPlaced = placedKinds.contains(selectedDeviceKind)
            previewCoordinator.update(isPlaced: isPlaced)
            distanceGate.update(for: selectedDeviceKind, isPlaced: isPlaced)
        }
    }
}
