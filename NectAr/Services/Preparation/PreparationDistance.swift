//
//  PreparationDistance.swift
//  NectAr
//

import Foundation
import RealityKit
import ARKit
import UIKit

@Observable
final class PreparationDistance {
    private static let maxPlacementDistance: Float = 3.0
    private static var hintHoldDuration: TimeInterval { 1 }

    weak var arView: ARView?
    /// Live, ungated, used to gate `PlacementController.confirmPlacement()` so
    /// a stale held `hint` never blocks a placement that's actually in range.
    private(set) var isTooFar = false
    /// Held for at least `hintHoldDuration` once shown, so rapid distance
    /// changes don't flicker unreadable text, see `advanceNow()`.
    private(set) var hint: String?
    private var hintHoldTask: Task<Void, Never>?

    func update(for kind: DeviceKind, isPlaced: Bool) {
        let rawHint = rawHint(for: kind, isPlaced: isPlaced)
        isTooFar = rawHint != nil

        guard hintHoldTask == nil else { return }
        applyHint(rawHint)
    }

    private func rawHint(for kind: DeviceKind, isPlaced: Bool) -> String? {
        guard let arView, !isPlaced else { return nil }

        let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        guard let raycastHit = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any).first else {
            return nil
        }

        let hitPosition = Transform(matrix: raycastHit.worldTransform).translation
        let distance = simd_distance(arView.cameraTransform.translation, hitPosition)
        return distance > Self.maxPlacementDistance ? "Move closer to place \(kind.label)" : nil
    }

    private func applyHint(_ text: String?) {
        hint = text
        guard text != nil else { return }
        hintHoldTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(Self.hintHoldDuration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            self?.hintHoldTask = nil
        }
    }

    /// Cuts the current hint's hold short, called when the card is tapped
    /// instead of waiting out the default duration.
    func advanceNow() {
        hintHoldTask?.cancel()
        hintHoldTask = nil
    }

    func reset() {
        hintHoldTask?.cancel()
        hintHoldTask = nil
        isTooFar = false
        hint = nil
    }
}
