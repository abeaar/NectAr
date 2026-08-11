//
//  RouterRangeVisualizer.swift
//  NectAr
//

import RealityKit
import UIKit

enum RouterRangeVisualizer {
    private static let fillOpacity: Float = 0.22
    private static let fillColor = UIColor(red: 0.8824, green: 0.7451, blue: 0.9059, alpha: 1) // #E1BEE7

    static func attach(to entity: Entity, range: Float) {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: fillColor, texture: nil)
        material.roughness = .init(floatLiteral: 1.0)
        material.metallic = .init(floatLiteral: 0.0)
        material.faceCulling = .none
        material.blending = .transparent(opacity: .init(floatLiteral: fillOpacity))

        let sphere = ModelEntity(
            mesh: .generateSphere(radius: range),
            materials: [material]
        )
        entity.addChild(sphere)
    }
}
