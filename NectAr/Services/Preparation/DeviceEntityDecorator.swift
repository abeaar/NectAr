//
//  DeviceEntityDecorator.swift
//  NectAr
//

import Foundation
import RealityKit

enum DeviceEntityDecorator {
    /// Per-kind scale tuned against the diorama-authored default, applied here
    /// individually rather than in `Scene.usda`.
    private static let deviceAScale: Float = 0.05
    private static let deviceBScale: Float = 0.5
    private static let routerScale: Float = 0.4

    static func decorate(_ entity: Entity, for kind: DeviceKind, includeRangeSphere: Bool = true) {
        entity.components.set(DeviceIdentityComponent(kind: kind))
        entity.components.set(HighlightComponent())

        if kind == .router {
            if includeRangeSphere {
                attachRangeSphereIfNeeded(to: entity, for: kind)
            }
        } else {
            entity.components.set(DeviceAttributesComponent(attributes: DeviceAttributes()))
        }

        entity.scale = SIMD3<Float>(repeating: scale(for: kind))
    }

    private static func scale(for kind: DeviceKind) -> Float {
        switch kind {
        case .deviceA: deviceAScale
        case .deviceB: deviceBScale
        case .router: routerScale
        }
    }

    /// Attaches the router's live attribute state, sphere hidden until the debug
    /// toggle shows it. `RangeVisualizationSystem` reacts to the components.
    static func attachRangeSphereIfNeeded(to entity: Entity, for kind: DeviceKind) {
        guard kind == .router else { return }
        entity.components.set(RouterAttributesComponent(attributes: RouterAttributes()))
        entity.components.set(RangeSphereVisibilityComponent(isVisible: false))
    }
}
