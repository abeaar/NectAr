import RealityKit

enum AnchoredEntityPlacer {
    /// Anchors `entity` at `transform` in world space and adds it to `scene`.
    ///
    /// The entity is parented under a world-origin (identity) anchor rather than an
    /// anchor placed directly at `transform`, so that a later `entity.move(to:relativeTo: nil, ...)`
    /// call is interpreted in world space rather than relative to a non-identity parent.
    @discardableResult
    static func place(_ entity: Entity, at transform: simd_float4x4, in scene: RealityKit.Scene) -> AnchorEntity {
        // Save the original scale so it isn't overwritten by the transform matrix
        let originalScale = entity.scale
        
        entity.transform = Transform(matrix: transform)
        entity.scale = originalScale // Restore the custom scale
        
        let anchor = AnchorEntity(world: matrix_identity_float4x4)
        anchor.addChild(entity)
        scene.addAnchor(anchor)
        return anchor
    }

    static func remove(_ anchor: AnchorEntity, from scene: RealityKit.Scene) {
        scene.removeAnchor(anchor)
    }
}
