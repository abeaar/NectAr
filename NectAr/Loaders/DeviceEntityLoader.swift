//
//  DevicesEntityLoader.swift
//  NectAr
//
//  Created by abr on 03/08/26.
//

import Foundation
import RealityKit
import ARWolrd

/// Loads every placeable entity from `ARWolrd`'s composed scene, authored in Reality
/// Composer Pro with all five entities referenced together in one `Scene.usda`.
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
        try await loadFromComposedScene(named: "Mail")
    }

    static func loadMascot() async throws -> Entity {
        try await loadFromComposedScene(named: "Bee")
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
