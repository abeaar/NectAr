import Foundation
import RealityKit
import ARKit
import Bee

@Observable
final class MascotOnboardingController: ARSceneDriven {
    private static let beeScale: Float = 0.5

    enum Phase {
        case hunting
        case animating
        case complete
    }

    private(set) var phase: Phase = .hunting

    var isActive: Bool { phase != .complete }

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

                let transform = MascotSpawnPlacer.randomSpawnTransform(around: arView.cameraTransform)
                let anchor = AnchoredEntityPlacer.place(entity, at: transform, in: arView.scene)

                beeEntity = entity
                beeAnchor = anchor
            } catch {
                print("Failed to load Bee entity: \(error)")
            }
        }
    }

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
            guard let self, let arView = self.arView, let beeEntity = self.beeEntity else { return }
            do {
                try await MascotFoundSequence.play(beeEntity, before: arView)
                self.phase = .complete
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

        if let arView, let beeAnchor {
            AnchoredEntityPlacer.remove(beeAnchor, from: arView.scene)
        }
        beeEntity = nil
        beeAnchor = nil
        phase = .hunting
    }
}
