//
//  DeviceEntityDecorator.swift
//  NectAr
//

import Foundation
import RealityKit

enum DeviceEntityDecorator {
    private static let markerLabelHeight: Float = 0.15
    private static let routerLabelHeight: Float = 0.3

    static func decorate(_ entity: Entity, for kind: DeviceKind, includeRangeSphere: Bool = true) {
        let labelHeight = kind == .router ? routerLabelHeight : markerLabelHeight
        EntityLabelAttacher.attach(labelText(for: kind), to: entity, height: labelHeight)

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

    /// Attaches the router's live attribute state without re-attaching the label.
    /// `RangeVisualizationSystem` reacts to it, sphere hidden until the debug toggle shows it.
    static func attachRangeSphereIfNeeded(to entity: Entity, for kind: DeviceKind) {
        guard kind == .router else { return }
        entity.components.set(RouterAttributesComponent(attributes: RouterAttributes()))
        entity.components.set(RangeSphereVisibilityComponent(isVisible: false))
    }

    private static func labelText(for kind: DeviceKind) -> String {
        kind == .router ? "WiFi Box" : kind.label
    }
}
