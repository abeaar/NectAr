import RealityKit
import UIKit

/// Keeps a placed router's range sphere in sync with its `RouterAttributesComponent`
/// and `RangeSphereVisibilityComponent`, rebuilding it whenever either changes
/// instead of requiring a manual call.
final class RangeVisualizationSystem: System {
    static let query = EntityQuery(where: .has(RouterAttributesComponent.self))

    private static let fillOpacity: Float = 0.22
    private static let fillColor = UIColor(red: 0.8824, green: 0.7451, blue: 0.9059, alpha: 1) // #E1BEE7
    private static let sphereName = "RangeSphere"

    private struct RenderedState: Equatable {
        var attributes: RouterAttributes
        var isVisible: Bool
    }
    private var lastRendered: [Entity.ID: RenderedState] = [:]

    init(scene: Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.scene.performQuery(Self.query) {
            guard let attributes = entity.components[RouterAttributesComponent.self]?.attributes else { continue }
            let isVisible = entity.components[RangeSphereVisibilityComponent.self]?.isVisible ?? true
            let state = RenderedState(attributes: attributes, isVisible: isVisible)
            guard lastRendered[entity.id] != state else { continue }
            lastRendered[entity.id] = state
            refreshRangeSphere(on: entity, attributes: attributes, isVisible: isVisible)
        }
    }

    /// Rebuilds the translucent lavender range sphere on `entity` to match
    /// `attributes` and the current debug-toggle visibility.
    private func refreshRangeSphere(on entity: Entity, attributes: RouterAttributes, isVisible: Bool) {
        entity.findEntity(named: Self.sphereName)?.removeFromParent()
        guard attributes.isOn, isVisible else { return }

        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: Self.fillColor, texture: nil)
        material.roughness = .init(floatLiteral: 1.0)
        material.metallic = .init(floatLiteral: 0.0)
        material.faceCulling = .none
        material.blending = .transparent(opacity: .init(floatLiteral: Self.fillOpacity))

        let sphere = ModelEntity(
            mesh: .generateSphere(radius: attributes.range),
            materials: [material]
        )
        sphere.name = Self.sphereName
        entity.addChild(sphere)
    }
}
