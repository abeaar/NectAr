//
//  MascotFoundSequence.swift
//  NectAr
//

import RealityKit
import ARKit

/// The two flight legs the bee plays once found: approaching to pose in front of the
/// camera, then, after the intro pause, flying through the camera as if entering it.
enum MascotFoundSequence {
    private static let flightDuration: TimeInterval = 2
    private static let cameraFrontDistance: Float = 1.0
    private static let enterDuration: TimeInterval = 1.2
    private static let enterOvershootDistance: Float = 0.6
    private static let enterFrameInterval: TimeInterval = 1.0 / 60.0
    private static let enterEndScale: Float = 0.001

    static func approachCamera(_ entity: Entity, before arView: ARView) async throws {
        let cameraPosition = arView.cameraTransform.translation
        let forward = -arView.cameraTransform.matrix.columns.2.xyz
        let frontPosition = cameraPosition + forward * cameraFrontDistance

        let startTransform = entity.transform
        var target = startTransform
        target.translation = frontPosition

        // The bee asset's authored front is +Z, not RealityKit's -Z default, so
        // `look(at:)` needs `forward: .positiveZ` here or it faces away.
        entity.look(at: cameraPosition, from: frontPosition, relativeTo: nil, forward: .positiveZ)
        target.rotation = entity.transform.rotation
        entity.transform = startTransform

        entity.move(to: target, relativeTo: nil, duration: flightDuration, timingFunction: .easeInOut)
        try await Task.sleep(nanoseconds: UInt64(flightDuration * 1_000_000_000))
    }

    /// Flies past the camera position while shrinking and fading out, so it reads as
    /// entering the device instead of just clipping through the near camera plane.
    static func enterCamera(_ entity: Entity, before arView: ARView) async throws {
        let forward = -arView.cameraTransform.matrix.columns.2.xyz
        let endPosition = arView.cameraTransform.translation + forward * enterOvershootDistance

        let start = entity.transform
        let endScale = SIMD3<Float>(repeating: enterEndScale)
        entity.components.set(OpacityComponent(opacity: 1))

        let startTime = Date()
        while true {
            let elapsed = Date().timeIntervalSince(startTime)
            let t = min(Float(elapsed / enterDuration), 1)

            var transform = start
            transform.translation = simd_mix(start.translation, endPosition, SIMD3(repeating: t))
            transform.scale = simd_mix(start.scale, endScale, SIMD3(repeating: t))
            entity.transform = transform
            entity.components[OpacityComponent.self]?.opacity = 1 - t

            if t >= 1 { break }
            try await Task.sleep(nanoseconds: UInt64(enterFrameInterval * 1_000_000_000))
            try Task.checkCancellation()
        }
    }
}

private extension simd_float4 {
    var xyz: SIMD3<Float> { SIMD3(x, y, z) }
}
