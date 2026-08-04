import ARKit
import simd

enum WallObstructionChecker {
    /// Padding added to each detected wall's bounds to absorb noisy real-world plane edges.
    private static let boundsPadding: Float = 0.075

    /// Returns whether a real detected wall lies between `from` and `to`.
    static func isObstructed(from: simd_float4x4, to: simd_float4x4, planes: [ARPlaneAnchor]) -> Bool {
        let walls = planes.filter { $0.alignment == .vertical }
        return walls.contains { wall in
            isSegment(from: from.translation, to: to.translation, obstructedBy: wall)
        }
    }

    private static func isSegment(from: simd_float3, to: simd_float3, obstructedBy wall: ARPlaneAnchor) -> Bool {
        let worldToLocal = wall.transform.inverse
        let localFrom = (worldToLocal * simd_float4(from, 1)).xyz
        let localTo = (worldToLocal * simd_float4(to, 1)).xyz

        // The plane's surface is the local XZ plane (normal along local Y).
        guard localFrom.y.sign != localTo.y.sign else { return false }

        let t = localFrom.y / (localFrom.y - localTo.y)
        let intersection = localFrom + (localTo - localFrom) * t

        // Ignores planeExtent.rotationOnYAxis for simplicity — the padding below absorbs
        // the resulting slack for near-square wall patches.
        let extent = wall.planeExtent
        let halfWidth = extent.width / 2 + boundsPadding
        let halfHeight = extent.height / 2 + boundsPadding

        let dx = intersection.x - wall.center.x
        let dz = intersection.z - wall.center.z
        return abs(dx) <= halfWidth && abs(dz) <= halfHeight
    }
}

private extension simd_float4x4 {
    var translation: simd_float3 {
        simd_float3(columns.3.x, columns.3.y, columns.3.z)
    }
}

private extension simd_float4 {
    var xyz: simd_float3 { simd_float3(x, y, z) }
}
