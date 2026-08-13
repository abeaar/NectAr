import RealityKit

/// Moves the mascot to trail behind the mail packet while it's guiding, reacting to
/// the mail's live position every frame rather than being driven step by step the
/// way its own onboarding flight is. Only the mail packet's own `Task` moves it;
/// the mascot has no movement of its own to synchronize against, it just tracks
/// wherever the mail currently is, so a System fits here where it didn't for the
/// mail or the onboarding flight.
final class MascotFollowSystem: System {
    private static let mascotQuery = EntityQuery(where: .has(MascotStateComponent.self))
    private static let mailQuery = EntityQuery(where: .has(RouteComponent.self))
    /// Placeholder offset behind and above the mail packet, needs visual tuning in Xcode.
    private static let trailOffset = SIMD3<Float>(-0.1, 0.15, 0.15)

    init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        guard let mascot = Array(context.scene.performQuery(Self.mascotQuery)).first(where: {
            $0.components[MascotStateComponent.self]?.phase == .guiding
        }) else { return }
        guard let mail = Array(context.scene.performQuery(Self.mailQuery)).first else { return }

        mascot.setPosition(mail.position(relativeTo: nil) + Self.trailOffset, relativeTo: nil)
    }
}
