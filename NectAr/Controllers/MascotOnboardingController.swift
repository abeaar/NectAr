import Foundation
import RealityKit
import ARKit
import Combine
import UIKit

@Observable
final class MascotOnboardingController: ARSceneDriven {
    static let beeScale: Float = 0.5
    private static let hoverDwellDuration: TimeInterval = 0.45
    private static let introPauseDuration: TimeInterval = 2
    private static let wanderRadius: Float = 0.4

    /// Stored so SwiftUI re-renders on change, mirrored onto the bee entity's
    /// `MascotStateComponent` in `didSet`, using its `Phase` type directly.
    private(set) var phase: MascotStateComponent.Phase = .hunting {
        didSet {
            beeEntity?.components[MascotStateComponent.self]?.phase = phase
        }
    }
    var isActive: Bool { phase != .complete }

    /// Narration source for the hunt/found beats, shared with `PlacementController`
    /// so the explanation card reads as one continuous sequence across both.
    private(set) var prepExplainService: PrepExplainService?

    func attachPrepExplainService(_ service: PrepExplainService) {
        prepExplainService = service
        if phase == .hunting {
            service.step(to: "1")
        }
    }

    weak var arView: ARView? {
        didSet {
            guard arView != nil else { return }
            spawn()
            subscribeToSceneUpdates()
        }
    }
    private var beeEntity: Entity?
    private var beeAnchor: AnchorEntity?
    private var sequenceTask: Task<Void, Never>?
    private var updateSubscription: Cancellable?
    private var hoverStartTime: Date?

    private func spawn() {
        guard let arView, beeEntity == nil else { return }

        Task {
            do {
                let entity = try await DeviceEntityLoader.loadMascot()
                entity.scale = SIMD3<Float>(repeating: Self.beeScale)
                entity.generateCollisionShapes(recursive: true)
                entity.components.set(MascotStateComponent(phase: .hunting))

                var sparkles = ParticleEmitterComponent()
                sparkles.emitterShape = .sphere
                sparkles.emitterShapeSize = SIMD3<Float>(repeating: 0.05)
                sparkles.speed = 0.05
                sparkles.speedVariation = 0.02
                sparkles.mainEmitter.birthRate = 40
                sparkles.mainEmitter.size = 0.006
                sparkles.mainEmitter.sizeVariation = 0.002
                sparkles.mainEmitter.lifeSpan = 0.6
                sparkles.mainEmitter.lifeSpanVariation = 0.2
                sparkles.mainEmitter.acceleration = SIMD3<Float>(0, 0.05, 0)
                sparkles.mainEmitter.color = .constant(.single(UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1)))
                entity.components.set(sparkles)

                let transform = MascotSpawnPlacer.randomSpawnTransform(around: arView.cameraTransform)
                let anchor = AnchoredEntityPlacer.place(entity, at: transform, in: arView.scene)
                entity.components.set(MascotMovementComponent(
                    pattern: .idleWander(center: entity.position(relativeTo: nil), radius: Self.wanderRadius)
                ))

                beeEntity = entity
                beeAnchor = anchor
            } catch {
                print("Failed to load Bee entity: \(error)")
            }
        }
    }

    private func subscribeToSceneUpdates() {
        guard let arView, updateSubscription == nil else { return }
        updateSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] _ in
            self?.checkHover()
        }
    }

    /// Runs every frame while hunting: the bee is found once the crosshair holds on
    /// it for `hoverDwellDuration`, no tap needed.
    private func checkHover() {
        guard phase == .hunting, let arView, let beeEntity else {
            hoverStartTime = nil
            return
        }

        let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        guard let hit = arView.entity(at: center), Self.isEntity(hit, containedIn: beeEntity) else {
            hoverStartTime = nil
            return
        }

        guard let startTime = hoverStartTime else {
            hoverStartTime = Date()
            return
        }
        guard Date().timeIntervalSince(startTime) >= Self.hoverDwellDuration else { return }

        hoverStartTime = nil
        beginFoundSequence()
    }

    /// Lets a direct tap on the bee find it immediately, without waiting on the
    /// hover dwell, forwarded here from `ARContainerView`'s tap gesture.
    func handleTap(at location: CGPoint, in arView: ARView) {
        guard phase == .hunting, let beeEntity else { return }
        guard let hit = arView.entity(at: location), Self.isEntity(hit, containedIn: beeEntity) else { return }

        hoverStartTime = nil
        beginFoundSequence()
    }

    private func beginFoundSequence() {
        phase = .animating
        sequenceTask?.cancel()
        sequenceTask = Task { [weak self] in
            guard let self, let arView = self.arView, let beeEntity = self.beeEntity else { return }
            do {
                prepExplainService?.step(to: "2")
                try await MascotFoundSequence.approachCamera(beeEntity, before: arView)

                try await Task.sleep(nanoseconds: UInt64(Self.introPauseDuration * 1_000_000_000))

                prepExplainService?.clear()
                try await MascotFoundSequence.enterCamera(beeEntity, before: arView)

                beeEntity.isEnabled = false
                self.phase = .complete
                prepExplainService?.step(to: "3")
            } catch {
            }
        }
    }

    private static func isEntity(_ entity: Entity, containedIn root: Entity) -> Bool {
        var current: Entity? = entity
        while let node = current {
            if node === root { return true }
            current = node.parent
        }
        return false
    }

    func tearDown() {
        sequenceTask?.cancel()
        sequenceTask = nil
        updateSubscription?.cancel()
        updateSubscription = nil
        hoverStartTime = nil

        if let arView, let beeAnchor {
            AnchoredEntityPlacer.remove(beeAnchor, from: arView.scene)
        }
        beeEntity = nil
        beeAnchor = nil
        phase = .hunting
    }
}
