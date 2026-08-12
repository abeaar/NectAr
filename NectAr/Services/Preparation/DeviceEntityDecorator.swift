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

        if includeRangeSphere {
            attachRangeSphereIfNeeded(to: entity, for: kind)
        }
    }

    /// Adds just the range sphere, without re-attaching the label. Used when promoting
    /// an already-decorated preview entity (label already attached) to a real placement.
    static func attachRangeSphereIfNeeded(to entity: Entity, for kind: DeviceKind) {
        guard kind == .router else { return }
        let attributes = RouterAttributes()
        if attributes.isOn {
            RouterRangeVisualizer.attach(to: entity, range: attributes.range)
        }
    }

    private static func labelText(for kind: DeviceKind) -> String {
        kind == .router ? "WiFi Box" : kind.label
    }
}
