//
//  MascotFoundSequence.swift
//  NectAr
//

import RealityKit
import ARKit

enum MascotFoundSequence {
    private static let poseDuration: TimeInterval = 2
    private static let flightDuration: TimeInterval = 2
    private static let cameraFrontDistance: Float = 1.0
    private static let nudgeRightOffset: Float = 0.22
    private static let nudgeDownOffset: Float = -0.32
    private static let nudgeForwardOffset: Float = 0.5

    static func play(_ entity: Entity, before arView: ARView) async throws {
        let camera = arView.cameraTransform
        let cameraPosition = camera.translation
        let forward = -camera.matrix.columns.2.xyz
        let right = camera.matrix.columns.0.xyz
        let up = camera.matrix.columns.1.xyz

        let frontPosition = cameraPosition + forward * cameraFrontDistance
        try await move(entity, to: frontPosition, facingCamera: cameraPosition, duration: flightDuration)

        try await Task.sleep(nanoseconds: UInt64(poseDuration * 1_000_000_000))

        let nudgePosition = cameraPosition
            + right * nudgeRightOffset
            + up * nudgeDownOffset
            + forward * nudgeForwardOffset
        try await move(entity, to: nudgePosition, duration: flightDuration)
    }

    private static func move(_ entity: Entity, to position: SIMD3<Float>, facingCamera cameraPosition: SIMD3<Float>? = nil, duration: TimeInterval) async throws {
        let startTransform = entity.transform
        var target = startTransform
        target.translation = position

        if let cameraPosition {
            // The bee asset's authored front is +Z, not RealityKit's -Z default, so
            // `look(at:)` needs `forward: .positiveZ` here or it faces away.
            entity.look(at: cameraPosition, from: position, relativeTo: nil, forward: .positiveZ)
            target.rotation = entity.transform.rotation
            entity.transform = startTransform
        }

        entity.move(to: target, relativeTo: nil, duration: duration, timingFunction: .easeInOut)
        try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
    }
}

private extension simd_float4 {
    var xyz: SIMD3<Float> { SIMD3(x, y, z) }
}
