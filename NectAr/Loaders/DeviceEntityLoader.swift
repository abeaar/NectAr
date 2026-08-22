//
//  DevicesEntityLoader.swift
//  NectAr
//
//  Created by abr on 03/08/26.
//

import Foundation
import RealityKit
import ARWolrd
import Bee
import Mail_3d
import Router_3d

/// Loads every placeable entity plus the mail packet from `ARWolrd`'s composed
/// scene, except the mascot, which loads from its own package, see `loadMascot()`.
enum DeviceEntityLoader {
    /// The composed scene, loaded once and cached. Each entity's authored scale in
    /// `Scene.usda` is its real placed size, since `AnchoredEntityPlacer` keeps it.
    private static var composedScene: Entity?

    static func load(_ kind: DeviceKind) async throws -> Entity {
        let entityName: String
        switch kind {
        case .router: entityName = "Router_3d"
        case .deviceA: entityName = "Iphone"
        case .deviceB: entityName = "MacBook"
        }
        return try await loadFromComposedScene(named: entityName)
    }

    static func loadMailPacket() async throws -> Entity {
        guard let scene = try? await Entity(named: "Mail", in: mail_3dBundle),
              let mail = scene.findEntity(named: "Root") else {
            throw LoadError.entityNotFound("Mail")
        }
        return mail.clone(recursive: true)
    }

    /// Loads from the standalone `Bee` package, not `ARWolrd`'s composed scene,
    /// since its wing-flap Behavior never fires when reached through a reference arc.
    static func loadMascot() async throws -> Entity {
        guard let asset = try? await Entity(named: "Bee", in: beeBundle),
              let bee = asset.findEntity(named: "Root") else {
            throw LoadError.entityNotFound("Bee")
        }
        return bee.clone(recursive: true)
    }

    /// Hands back a clone of the named child, not the cached entity itself, since
    /// anchoring reparents it and would otherwise remove it from the cache.
    private static func loadFromComposedScene(named name: String) async throws -> Entity {
        if composedScene == nil {
            composedScene = try await Entity(named: "Scene", in: aRWolrdBundle)
        }
        guard let template = composedScene?.findEntity(named: name) else {
            throw LoadError.entityNotFound(name)
        }
        return template.clone(recursive: true)
    }

    private enum LoadError: Error {
        case entityNotFound(String)
    }
}
