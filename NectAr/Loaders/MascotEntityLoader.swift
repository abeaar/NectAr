import RealityKit
import Bee

/// Loads the bee mascot entity and attaches its live state component, mirroring
/// `DeviceEntityLoader`'s creation pattern for the other three entities.
enum MascotEntityLoader {
    /// Placeholder scale, the asset's raw authored size reads too large on screen.
    private static let beeScale: Float = 0.5

    static func load() async throws -> Entity {
        let entity = try await Entity(named: "Bee", in: beeBundle)
        entity.generateCollisionShapes(recursive: true)
        entity.scale = SIMD3<Float>(repeating: beeScale)
        entity.components.set(MascotStateComponent(phase: .hunting))
        return entity
    }
}
