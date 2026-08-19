import RealityKit
import UIKit

enum PreparationPreviewStyler {
    /// In and out of placement range, so the ghost itself hints whether the
    /// current spot is actually placeable.
    private static let ghostColorInRange = UIColor(hex: 0x1EFF00)
    private static let ghostColorOutOfRange = UIColor(hex: 0xFF383C)
    static let ghostOpacity: PhysicallyBasedMaterial.Opacity = 0.5

    /// The materials each model entity had before ghosting, so a preview entity can
    /// later be promoted to a real placement without reloading it from scratch.
    struct OriginalMaterials {
        fileprivate let entries: [(ModelEntity, [Material])]
    }

    @discardableResult
    static func applyGhostMaterial(to entity: Entity, isInRange: Bool = false) -> OriginalMaterials {
        var saved: [(ModelEntity, [Material])] = []
        for modelEntity in modelEntities(in: entity) {
            let materials = modelEntity.model?.materials ?? []
            saved.append((modelEntity, materials))
        }
        updateGhostColor(on: entity, isInRange: isInRange)
        return OriginalMaterials(entries: saved)
    }

    /// Re-tints just the ghost color, leaving `OriginalMaterials` already
    /// captured by `applyGhostMaterial` untouched.
    static func updateGhostColor(on entity: Entity, isInRange: Bool) {
        var ghostMaterial = UnlitMaterial(color: isInRange ? ghostColorInRange : ghostColorOutOfRange)
        ghostMaterial.blending = .transparent(opacity: ghostOpacity)

        for modelEntity in modelEntities(in: entity) {
            let materialCount = max(modelEntity.model?.materials.count ?? 0, 1)
            modelEntity.model?.materials = Array(repeating: ghostMaterial, count: materialCount)
        }
    }

    static func restoreOriginalMaterial(_ original: OriginalMaterials) {
        for (modelEntity, materials) in original.entries {
            modelEntity.model?.materials = materials
        }
    }

    private static func modelEntities(in entity: Entity) -> [ModelEntity] {
        var result: [ModelEntity] = []
        if let modelEntity = entity as? ModelEntity {
            result.append(modelEntity)
        }
        for child in entity.children {
            result.append(contentsOf: modelEntities(in: child))
        }
        return result
    }
}

private extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: alpha
        )
    }
}
