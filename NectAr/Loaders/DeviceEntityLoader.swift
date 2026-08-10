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

/// Builds the RealityKit entity for each placed node, including its floating text
/// label. Device markers are procedural discs, not package assets.
enum DeviceEntityLoader {
    private static let markerLabelHeight: Float = 0.15
    private static let routerLabelHeight: Float = 0.3

    private static let rangeSphereFillOpacity: Float = 0.22
    private static let rangeSphereFillColor = UIColor(red: 0.8824, green: 0.7451, blue: 0.9059, alpha: 1) // #E1BEE7

    private struct ModelDescriptor {
        let entityName: String
        let bundle: Bundle
        let scale: SIMD3<Float>
        let labelHeight: Float
    }

    /// Kinds with a dedicated 3D asset. A kind absent from this table falls back to the
    /// procedural marker disc — adding a future kind with its own model is then just one
    /// entry here, no other change in this file.
    private static let modelDescriptors: [DeviceKind: ModelDescriptor] = [
        // Placeholder scale, needs visual tuning against a real router-sized object.
        .router: ModelDescriptor(entityName: "Router_3d", bundle: router_3dBundle, scale: [1.0, 1.0, 1.0], labelHeight: routerLabelHeight)
    ]

    /// Loads the entity for `kind` and attaches its floating label. `includeRangeSphere`
    /// gates the ghost preview off so the sphere only shows once the router is placed.
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
                    attachRangeSphere(to: entity, range: attributes.range)
                }
            }
        } else {
            entity = makeDeviceMarker()
            labelHeight = markerLabelHeight
        }

        attachLabel(labelText(for: kind), to: entity, height: labelHeight)
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

    /// A flat disc lying face-up so it reads clearly on a horizontal surface
    /// (device markers are only ever placed horizontally, per PRD G3).
    private static func makeDeviceMarker() -> Entity {
        let radius: Float = 0.001
        let thickness: Float = 0.002

        return ModelEntity(
            mesh: .generateCylinder(height: thickness, radius: radius),
            materials: [SimpleMaterial(color: .white, isMetallic: false)]
        )
    }

    /// Placeholder wifi-range visualization: a translucent lavender sphere sized to
    /// `range`, using `PhysicallyBasedMaterial` so it's visible even with the camera
    /// inside it.
    private static func attachRangeSphere(to entity: Entity, range: Float) {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: rangeSphereFillColor, texture: nil)
        material.roughness = .init(floatLiteral: 1.0)
        material.metallic = .init(floatLiteral: 0.0)
        material.faceCulling = .none
        material.blending = .transparent(opacity: .init(floatLiteral: rangeSphereFillOpacity))

        let sphere = ModelEntity(
            mesh: .generateSphere(radius: range),
            materials: [material]
        )
        entity.addChild(sphere)
    }

    /// Adds a camera-facing text tag above `entity` so it reads as a floating label
    /// regardless of the entity's own orientation.
    private static func attachLabel(_ text: String, to entity: Entity, height: Float) {
        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.001,
            font: .systemFont(ofSize: 0.05),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        let textEntity = ModelEntity(mesh: mesh, materials: [UnlitMaterial(color: .white)])
        // generateText anchors the mesh at its bottom-left; recenter it horizontally.
        textEntity.position.x = -mesh.bounds.extents.x / 2

        let label = Entity()
        label.addChild(textEntity)
        label.components.set(BillboardComponent())
        label.position.y = height

        entity.addChild(label)
    }
}
