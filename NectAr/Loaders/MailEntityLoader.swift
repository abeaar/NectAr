import RealityKit
import Router

/// Loads the mail packet entity animated during simulation, kept separate from
/// `DeviceEntityLoader` since it isn't one of the placeable `DeviceKind` entities.
enum MailEntityLoader {
    static func load() async throws -> Entity {
        let entity = try await Entity(named: "mail", in: routerBundle)
        // Hardcode the size (scale) of the mail packet here
        entity.scale = [0.3, 0.3, 0.3]
        return entity
    }
}
