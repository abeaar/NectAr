import RealityKit
import UIKit

/// Adds or removes a pulsing translucent highlight on any entity whose
/// `HighlightComponent.isHighlighted` changes, mirroring `RangeVisualizationSystem`.
struct HighlightSystem: System {
    static let query = EntityQuery(where: .has(HighlightComponent.self))

    private static let highlightName = "StepHighlight"
    private static let color = UIColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1)
    private static let radius: Float = 0.08
    private static let pulseDuration: TimeInterval = 0.6
    private static let pulseScale: Float = 1.4

    private var lastHighlighted: [Entity.ID: Bool] = [:]

    init(scene: Scene) {}

    mutating func update(context: SceneUpdateContext) {
        for entity in context.scene.performQuery(Self.query) {
            guard let isHighlighted = entity.components[HighlightComponent.self]?.isHighlighted else { continue }
            guard lastHighlighted[entity.id] != isHighlighted else { continue }
            lastHighlighted[entity.id] = isHighlighted
            refreshHighlight(on: entity, isHighlighted: isHighlighted)
        }
    }

    private func refreshHighlight(on entity: Entity, isHighlighted: Bool) {
        entity.findEntity(named: Self.highlightName)?.removeFromParent()
        guard isHighlighted else { return }

        var material = UnlitMaterial(color: Self.color)
        material.blending = .transparent(opacity: .init(floatLiteral: 0.5))
        let sphere = ModelEntity(mesh: .generateSphere(radius: Self.radius), materials: [material])
        sphere.name = Self.highlightName
        entity.addChild(sphere)

        startPulsing(sphere)
    }

    /// Loops the highlight's scale up and down until it's removed from its parent,
    /// which happens as soon as `isHighlighted` flips back to false.
    private func startPulsing(_ sphere: ModelEntity) {
        Task {
            while sphere.parent != nil {
                var grown = sphere.transform
                grown.scale = SIMD3<Float>(repeating: Self.pulseScale)
                sphere.move(to: grown, relativeTo: sphere.parent, duration: Self.pulseDuration, timingFunction: .easeInOut)
                try? await Task.sleep(nanoseconds: UInt64(Self.pulseDuration * 1_000_000_000))
                guard sphere.parent != nil else { break }

                var shrunk = sphere.transform
                shrunk.scale = SIMD3<Float>(repeating: 1.0)
                sphere.move(to: shrunk, relativeTo: sphere.parent, duration: Self.pulseDuration, timingFunction: .easeInOut)
                try? await Task.sleep(nanoseconds: UInt64(Self.pulseDuration * 1_000_000_000))
            }
        }
    }
}
