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

    weak var arView: ARView?
    private(set) var hint: String?

    func update(for kind: DeviceKind, isPlaced: Bool) {
        guard let arView, !isPlaced else {
            hint = nil
            return
        }

        let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        guard let raycastHit = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any).first else {
            hint = nil
            return
        }

        let hitPosition = Transform(matrix: raycastHit.worldTransform).translation
        let distance = simd_distance(arView.cameraTransform.translation, hitPosition)
        hint = distance > Self.maxPlacementDistance ? "Move closer to place \(kind.label)" : nil
    }

    func reset() {
        hint = nil
    }
}
