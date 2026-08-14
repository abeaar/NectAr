import RealityKit
import simd

/// Selects which movement pattern MascotFollowSystem plays for the bee each frame,
/// hopping between random points near a center while hunting, or trailing another
/// entity with a fixed offset while guiding it through the simulation.
struct MascotMovementComponent: Component {
    enum Pattern {
        case idleWander(center: SIMD3<Float>, radius: Float)
        case followOffset(SIMD3<Float>)
    }

    var pattern: Pattern
}
