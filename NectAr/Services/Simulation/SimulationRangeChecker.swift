import simd

enum SimulationRangeChecker {
    static func isInRange(device: simd_float4x4, router: simd_float4x4, range: Float) -> Bool {
        simd_distance(device.translation, router.translation) <= range
    }
}

private extension simd_float4x4 {
    var translation: simd_float3 {
        simd_float3(columns.3.x, columns.3.y, columns.3.z)
    }
}
