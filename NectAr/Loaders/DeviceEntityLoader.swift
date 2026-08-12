//
//  DevicesEntityLoader.swift
//  NectAr
//
//  Created by abr on 03/08/26.
//

import Foundation
import RealityKit
import UIKit
import Mail_3d
import Router_3d

enum DeviceEntityLoader {
    private static let markerLabelHeight: Float = 0.15
    private static let routerLabelHeight: Float = 0.3

    private struct ModelDescriptor {
        let entityName: String
        let bundle: Bundle
        let scale: SIMD3<Float>
        let labelHeight: Float
    }

    private static let modelDescriptors: [DeviceKind: ModelDescriptor] = [
        // Placeholder scale, needs visual tuning against a real router-sized object.
        .router: ModelDescriptor(entityName: "Router_3d", bundle: router_3dBundle, scale: [1.0, 1.0, 1.0], labelHeight: routerLabelHeight)
    ]

    static func load(_ kind: DeviceKind, includeRangeSphere: Bool = true) async throws -> Entity {
        let entity: Entity
        let labelHeight: Float

        if let descriptor = modelDescriptors[kind] {
            entity = try await Entity(named: descriptor.entityName, in: descriptor.bundle)
            entity.scale = descriptor.scale
            labelHeight = descriptor.labelHeight

            if kind == .router {
                let attributes = RouterAttributes()
                if includeRangeSphere && attributes.isOn {
                    RouterRangeVisualizer.attach(to: entity, range: attributes.range)
                }
            }
        } else {
            entity = makeDeviceMarker()
            labelHeight = markerLabelHeight
        }

        EntityLabelAttacher.attach(labelText(for: kind), to: entity, height: labelHeight)
        return entity
    }

    static func loadMailPacket() async throws -> Entity {
        let entity = try await Entity(named: "Mail", in: mail_3dBundle)
        // Hardcode the size (scale) of the mail packet here
        entity.scale = [0.3, 0.3, 0.3]
        return entity
    }

    private static func labelText(for kind: DeviceKind) -> String {
        kind == .router ? "WiFi Box" : kind.label
    }

    private static func makeDeviceMarker() -> Entity {
        let radius: Float = 0.001
        let thickness: Float = 0.002

        return ModelEntity(
            mesh: .generateCylinder(height: thickness, radius: radius),
            materials: [SimpleMaterial(color: .white, isMetallic: false)]
        )
    }
}
