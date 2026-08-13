import RealityKit
import simd

/// Wraps the mail packet's current route directly on its entity: the ordered
/// waypoints `SimulationSceneController` animates it through, and which one it's on.
struct RouteComponent: Component {
    var waypoints: [simd_float4x4]
    var currentIndex: Int = 0
}
