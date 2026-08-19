import simd
import RealityKit

/// Computes the rotation the mail packet should hold while traveling from
/// `origin` to `target`. Keeps the asset's authored front facing the direction
/// of travel and strips surface tilt so it doesn't inherit it.
enum MailFacing {
    static func rotation(from origin: SIMD3<Float>,
                         to target: SIMD3<Float>,
                         up: SIMD3<Float>) -> simd_quatf {
        guard simd_distance(origin, target) > 0.001 else { return simd_quatf() }
        let anchor = Entity()
        anchor.look(at: target, from: origin, relativeTo: nil, forward: .positiveZ)
        return anchor.transform.rotation
    }
}
