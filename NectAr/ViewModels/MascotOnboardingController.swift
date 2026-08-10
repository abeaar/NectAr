import Foundation
import RealityKit
import ARKit
import Bee

/// Temporary find-the-bee placement intro, standing in for the full onboarding flow
/// (guiding the user through each button group) that isn't built yet.
@Observable
final class MascotOnboardingController {
    /// Placeholder scale, the asset's raw authored size reads too large on screen.
    private static let beeScale: Float = 0.5
    private static let minSpawnDistance: Float = 1.5
    private static let maxSpawnDistance: Float = 4.0
    private static let spawnHeightJitter: Float = 0.3
    /// Half-width of the frontal arc the bee can spawn in, centered on the camera's
    /// forward direction at spawn time, so it never lands behind the user.
    private static let spawnArcHalfAngle: Float = .pi / 3
    private static let poseDuration: TimeInterval = 2
    private static let flightDuration: TimeInterval = 2
    private static let cameraFrontDistance: Float = 1.0
    /// Approximates the place button's screen position in camera-relative space,
    /// needs visual tuning in Xcode.
    private static let nudgeRightOffset: Float = 0.22
    private static let nudgeDownOffset: Float = -0.32
    private static let nudgeForwardOffset: Float = 0.5

    enum Phase {
        case hunting
        case animating
        case complete
    }

    private(set) var phase: Phase = .hunting
    /// True until the nudge animation finishes. Drives the place button's icon and
    /// gates the rest of the placement UI to inert while true.
    var isActive: Bool { phase != .complete }
    /// Shown as the placement hint for as long as the sequence is active.
    var mascotHint: String? {
        switch phase {
        case .hunting: "Look around to find the bee!"
        case .animating: "You found a Mythical Abee!"
        case .complete: nil
        }
    }

    weak var arView: ARView? {
        didSet {
            guard arView != nil else { return }
            spawn()
        }
    }
    private var beeEntity: Entity?
    private var beeAnchor: AnchorEntity?
    private var sequenceTask: Task<Void, Never>?

    private func spawn() {
        guard let arView, beeEntity == nil else { return }

        Task {
            do {
                let entity = try await Entity(named: "Bee", in: beeBundle)
                entity.generateCollisionShapes(recursive: true)
                entity.scale = SIMD3<Float>(repeating: Self.beeScale)

                let transform = Self.randomSpawnTransform(around: arView.cameraTransform)
                let anchor = AnchoredEntityPlacer.place(entity, at: transform, in: arView.scene)

                beeEntity = entity
                beeAnchor = anchor
            } catch {
                print("Failed to load Bee entity: \(error)")
            }
        }
    }

    /// Called when the user taps the place button while `phase == .hunting`. No-ops
    /// unless the crosshair is currently over the bee.
    func attemptFind() {
        guard phase == .hunting, let arView, let beeEntity else { return }

        let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        guard let hit = arView.entity(at: center), Self.isEntity(hit, containedIn: beeEntity) else {
            print("Crosshair isn't on the bee yet")
            return
        }

        phase = .animating
        sequenceTask?.cancel()
        sequenceTask = Task { [weak self] in
            await self?.playFoundSequence()
        }
    }

    private func playFoundSequence() async {
        guard let arView, let beeEntity else { return }

        do {
            let camera = arView.cameraTransform
            let cameraPosition = camera.translation
            let forward = -camera.matrix.columns.2.xyz
            let right = camera.matrix.columns.0.xyz
            let up = camera.matrix.columns.1.xyz

            let frontPosition = cameraPosition + forward * Self.cameraFrontDistance
            try await moveBee(beeEntity, to: frontPosition, facingCamera: cameraPosition, duration: Self.flightDuration)

            try await Task.sleep(nanoseconds: UInt64(Self.poseDuration * 1_000_000_000))

            let nudgePosition = cameraPosition
                + right * Self.nudgeRightOffset
                + up * Self.nudgeDownOffset
                + forward * Self.nudgeForwardOffset
            try await moveBee(beeEntity, to: nudgePosition, duration: Self.flightDuration)

            phase = .complete
        } catch {
            // Cancelled, either the controller went away or a new hunt restarted.
        }
    }

    /// Animates `entity` to `position`, optionally turning to face `cameraPosition`
    /// over the course of the move rather than snapping to it afterward.
    private func moveBee(_ entity: Entity, to position: SIMD3<Float>, facingCamera cameraPosition: SIMD3<Float>? = nil, duration: TimeInterval) async throws {
        let startTransform = entity.transform
        var target = startTransform
        target.translation = position

        if let cameraPosition {
            // The bee asset's authored front is +Z, not RealityKit's -Z default, so
            // `look(at:)` needs `forward: .positiveZ` here or it faces away.
            entity.look(at: cameraPosition, from: position, relativeTo: nil, forward: .positiveZ)
            target.rotation = entity.transform.rotation
            entity.transform = startTransform
        }

        entity.move(to: target, relativeTo: nil, duration: duration, timingFunction: .easeInOut)
        try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
    }

    /// Random point within a frontal arc centered on the camera's current forward
    /// direction, so the bee always spawns somewhere findable without turning around.
    private static func randomSpawnTransform(around cameraTransform: Transform) -> simd_float4x4 {
        let cameraForward = -cameraTransform.matrix.columns.2.xyz
        let flatForward = SIMD3<Float>(cameraForward.x, 0, cameraForward.z)
        let horizontalForward = simd_length(flatForward) > 0.001 ? simd_normalize(flatForward) : SIMD3<Float>(0, 0, -1)

        let angle = Float.random(in: -spawnArcHalfAngle...spawnArcHalfAngle)
        let cosA = cos(angle)
        let sinA = sin(angle)
        let direction = SIMD3<Float>(
            horizontalForward.x * cosA - horizontalForward.z * sinA,
            0,
            horizontalForward.x * sinA + horizontalForward.z * cosA
        )

        let distance = Float.random(in: minSpawnDistance...maxSpawnDistance)
        let heightJitter = Float.random(in: -spawnHeightJitter...spawnHeightJitter)
        let position = cameraTransform.translation + direction * distance + SIMD3(0, heightJitter, 0)

        var transform = matrix_identity_float4x4
        transform.columns.3 = SIMD4(position.x, position.y, position.z, 1)
        return transform
    }

    private static func isEntity(_ entity: Entity, containedIn root: Entity) -> Bool {
        var current: Entity? = entity
        while let node = current {
            if node === root { return true }
            current = node.parent
        }
        return false
    }

    /// Releases the spawned bee and cancels any in-flight sequence so nothing lingers
    /// once this controller itself goes away.
    deinit {
        sequenceTask?.cancel()
        guard let arView, let beeAnchor else { return }
        AnchoredEntityPlacer.remove(beeAnchor, from: arView.scene)
    }
}

private extension simd_float4 {
    var xyz: SIMD3<Float> { SIMD3(x, y, z) }
}
