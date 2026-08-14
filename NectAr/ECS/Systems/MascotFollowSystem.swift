import RealityKit
import Foundation

/// Drives the mascot's position every frame per its MascotMovementComponent pattern:
/// hopping near its spawn while hunting, or trailing the mail packet while guiding.
struct MascotFollowSystem: System {
    private static let mascotQuery = EntityQuery(where: .has(MascotMovementComponent.self))
    private static let mailQuery = EntityQuery(where: .has(RouteComponent.self))

    private static let wanderFlightDuration: TimeInterval = 1.2
    private static let wanderPauseDuration: TimeInterval = 1.0

    private struct WanderLeg {
        var origin: SIMD3<Float>
        var target: SIMD3<Float>
        var originRotation: simd_quatf
        var targetRotation: simd_quatf
        var legStartTime: Date
        var isPausing: Bool
    }
    private var wanderLegs: [Entity.ID: WanderLeg] = [:]

    init(scene: Scene) {}

    mutating func update(context: SceneUpdateContext) {
        for mascot in context.entities(matching: Self.mascotQuery, updatingSystemWhen: .rendering) {
            guard let phase = mascot.components[MascotStateComponent.self]?.phase,
                  let pattern = mascot.components[MascotMovementComponent.self]?.pattern else { continue }

            switch pattern {
            case .idleWander(let center, let radius):
                guard phase == .hunting else {
                    wanderLegs[mascot.id] = nil
                    continue
                }
                updateWander(mascot, center: center, radius: radius)

            case .followOffset(let offset):
                guard phase == .guiding,
                      let mail = Array(context.entities(matching: Self.mailQuery, updatingSystemWhen: .rendering)).first
                else { continue }
                mascot.setPosition(mail.position(relativeTo: nil) + offset, relativeTo: nil)
            }
        }
    }

    /// Flies to a random point near `center` facing the direction of travel, holds
    /// that facing while paused, then picks a new point, looping while hunting.
    private mutating func updateWander(_ entity: Entity, center: SIMD3<Float>, radius: Float) {
        let now = Date()
        var leg = wanderLegs[entity.id] ?? startNewLeg(from: entity.position(relativeTo: nil), entity: entity, center: center, radius: radius, now: now)

        if leg.isPausing {
            if now.timeIntervalSince(leg.legStartTime) >= Self.wanderPauseDuration {
                leg = startNewLeg(from: leg.target, entity: entity, center: center, radius: radius, now: now)
            }
        } else {
            let t = min(Float(now.timeIntervalSince(leg.legStartTime) / Self.wanderFlightDuration), 1)
            entity.setPosition(simd_mix(leg.origin, leg.target, SIMD3(repeating: t)), relativeTo: nil)
            entity.transform.rotation = simd_slerp(leg.originRotation, leg.targetRotation, t)
            if t >= 1 {
                leg.isPausing = true
                leg.legStartTime = now
            }
        }
        wanderLegs[entity.id] = leg
    }

    private func startNewLeg(from origin: SIMD3<Float>, entity: Entity, center: SIMD3<Float>, radius: Float, now: Date) -> WanderLeg {
        let offset = SIMD3<Float>(
            Float.random(in: -radius...radius),
            Float.random(in: -radius...radius),
            Float.random(in: -radius...radius)
        )
        let target = center + offset

        return WanderLeg(
            origin: origin,
            target: target,
            originRotation: entity.transform.rotation,
            targetRotation: Self.facingRotation(at: origin, toward: target, entity: entity),
            legStartTime: now,
            isPausing: false
        )
    }

    private static func facingRotation(at origin: SIMD3<Float>, toward target: SIMD3<Float>, entity: Entity) -> simd_quatf {
        let startTransform = entity.transform
        // The bee asset's authored front is +Z, not RealityKit's -Z default.
        entity.look(at: target, from: origin, relativeTo: nil, forward: .positiveZ)
        let rotation = entity.transform.rotation
        entity.transform = startTransform
        return rotation
    }
}
