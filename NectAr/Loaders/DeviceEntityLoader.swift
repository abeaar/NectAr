//
//  DevicesEntityLoader.swift
//  NectAr
//
//  Created by abr on 03/08/26.
//

import Foundation
import RealityKit
import UIKit
import Router
import Router_3d

/// Builds the RealityKit entity for each placed node, including its floating text
/// label. The router model is loaded from the ``Router_3d`` package bundle
/// (`router_3dBundle`); the mail-packet model still lives in the older ``Router``
/// package bundle (`routerBundle`). Device markers are procedural discs, not package
/// assets.
enum DeviceEntityLoader {
    private static let markerLabelHeight: Float = 0.15
    private static let routerLabelHeight: Float = 0.3
    
    private static let rangeSphereFillOpacity: Float = 0.22
    private static let rangeSphereFillColor = UIColor(red: 0.8824, green: 0.7451, blue: 0.9059, alpha: 1) // #E1BEE7

    /// Loads the entity for `kind` and attaches its floating label. `includeRangeSphere`
    /// gates the ghost preview off so the sphere only shows once the router is placed.
    static func load(_ kind: DeviceKind, includeRangeSphere: Bool = true) async throws -> Entity {
        let entity: Entity
        let labelHeight: Float

        switch kind {
        case .router:
            entity = try await Entity(named: "Router_3d", in: router_3dBundle)
            // Placeholder scale, needs visual tuning against a real router-sized object.
            entity.scale = [1.0, 1.0, 1.0]
            labelHeight = routerLabelHeight
            let attributes = RouterAttributes()
            if includeRangeSphere && attributes.isOn {
                attachRangeSphere(to: entity, range: attributes.range)
            }
        case .deviceA, .deviceB:
            entity = makeDeviceMarker()
            labelHeight = markerLabelHeight
        }

        attachLabel(labelText(for: kind), to: entity, height: labelHeight)
        return entity
    }

    static func loadMailPacket() async throws -> Entity {
        let entity = try await Entity(named: "mail", in: routerBundle)
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
