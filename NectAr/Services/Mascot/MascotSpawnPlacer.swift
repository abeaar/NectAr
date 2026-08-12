//
//  MascotSpawnPlacer.swift
//  NectAr
//

import RealityKit
import simd

enum MascotSpawnPlacer {
    private static let minSpawnDistance: Float = 1.5
    private static let maxSpawnDistance: Float = 4.0
    private static let spawnHeightJitter: Float = 0.3
    private static let spawnArcHalfAngle: Float = .pi / 3

    static func randomSpawnTransform(around cameraTransform: Transform) -> simd_float4x4 {
        let cameraForward = -cameraTransform.matrix.columns.2.xyz
        let flatForward = SIMD3<Float>(cameraForward.x, 0, cameraForward.z)
        let horizontalForward = simd_length(flatForward) > 0.001 ? simd_normalize(flatForward) : SIMD3<Float>(0, 0, -1)

        let angle = Float.random(in: -spawnArcHalfAngle...spawnArcHalfAngle)
        let cosA = cos(angle)
        let sinA = sin(angle)
        let direction = SIMD3<Float>(
            horizontalForward.x * cosA - horizontalForward.z * sinA,
            0,
            horizontalForward.x * sinA + horizontalForward.z * cosA
        )

        let distance = Float.random(in: minSpawnDistance...maxSpawnDistance)
        let heightJitter = Float.random(in: -spawnHeightJitter...spawnHeightJitter)
        let position = cameraTransform.translation + direction * distance + SIMD3(0, heightJitter, 0)

        var transform = matrix_identity_float4x4
        transform.columns.3 = SIMD4(position.x, position.y, position.z, 1)
        return transform
    }
}

private extension simd_float4 {
    var xyz: SIMD3<Float> { SIMD3(x, y, z) }
}
