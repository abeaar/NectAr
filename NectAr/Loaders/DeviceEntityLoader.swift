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
    private struct ModelDescriptor {
        let entityName: String
        let bundle: Bundle
        let scale: SIMD3<Float>
    }

    private static let modelDescriptors: [DeviceKind: ModelDescriptor] = [
        .router: ModelDescriptor(entityName: "Router_3d", bundle: router_3dBundle, scale: [1.0, 1.0, 1.0])
    ]

    static func load(_ kind: DeviceKind) async throws -> Entity {
        if let descriptor = modelDescriptors[kind] {
            return try await loadEntity(named: descriptor.entityName, in: descriptor.bundle, scale: descriptor.scale)
        }
        return makeDeviceMarker()
    }

    static func loadMailPacket() async throws -> Entity {
        try await loadEntity(named: "Mail", in: mail_3dBundle, scale: [0.3, 0.3, 0.3])
    }

    static func loadEntity(named name: String, in bundle: Bundle, scale: SIMD3<Float>) async throws -> Entity {
        let entity = try await Entity(named: name, in: bundle)
        entity.scale = scale
        return entity
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
