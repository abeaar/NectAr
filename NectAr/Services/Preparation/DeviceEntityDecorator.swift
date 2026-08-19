//
//  DeviceEntityDecorator.swift
//  NectAr
//

import Foundation
import RealityKit

enum DeviceEntityDecorator {
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
    }

    /// Attaches the router's live attribute state, sphere hidden until the debug
    /// toggle shows it. `RangeVisualizationSystem` reacts to the components.
    static func attachRangeSphereIfNeeded(to entity: Entity, for kind: DeviceKind) {
        guard kind == .router else { return }
        entity.components.set(RouterAttributesComponent(attributes: RouterAttributes()))
        entity.components.set(RangeSphereVisibilityComponent(isVisible: false))
    }
}
