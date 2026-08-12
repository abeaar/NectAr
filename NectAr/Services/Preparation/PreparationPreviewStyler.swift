import RealityKit
import UIKit

enum PreparationPreviewStyler {
    private static let ghostColor = UIColor(hex: 0x999999)
    private static let ghostOpacity: PhysicallyBasedMaterial.Opacity = 0.35

    /// The materials each model entity had before ghosting, so a preview entity can
    /// later be promoted to a real placement without reloading it from scratch.
    struct OriginalMaterials {
        fileprivate let entries: [(ModelEntity, [Material])]
    }

    @discardableResult
    static func applyGhostMaterial(to entity: Entity) -> OriginalMaterials {
        var ghostMaterial = UnlitMaterial(color: ghostColor)
        ghostMaterial.blending = .transparent(opacity: ghostOpacity)

        var saved: [(ModelEntity, [Material])] = []
        for modelEntity in modelEntities(in: entity) {
            let materials = modelEntity.model?.materials ?? []
            saved.append((modelEntity, materials))
            let materialCount = max(materials.count, 1)
            modelEntity.model?.materials = Array(repeating: ghostMaterial, count: materialCount)
        }
        return OriginalMaterials(entries: saved)
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
