//
//  EntityLabelAttacher.swift
//  NectAr
//

import RealityKit
import UIKit

enum EntityLabelAttacher {
    static func attach(_ text: String, to entity: Entity, height: Float) {
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
