import RealityKit

/// Moves the mascot to trail behind the mail packet while it's guiding, reacting
/// every frame to the mail's live position, which only its own `Task` moves.
struct MascotFollowSystem: System {
    private static let mascotQuery = EntityQuery(where: .has(MascotStateComponent.self))
    private static let mailQuery = EntityQuery(where: .has(RouteComponent.self))
    /// Placeholder offset behind and above the mail packet, needs visual tuning in Xcode.
    private static let trailOffset = SIMD3<Float>(-0.1, 0.15, 0.15)

    init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        guard let mascot = Array(context.entities(matching: Self.mascotQuery, updatingSystemWhen: .rendering)).first(where: {
            $0.components[MascotStateComponent.self]?.phase == .guiding
        }) else { return }
        guard let mail = Array(context.entities(matching: Self.mailQuery, updatingSystemWhen: .rendering)).first else { return }

        mascot.setPosition(mail.position(relativeTo: nil) + Self.trailOffset, relativeTo: nil)
    }
}
