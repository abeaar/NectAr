import RealityKit
import UIKit

/// Recolors a preview entity into a flat, translucent grey — the "not placed
/// yet" ghost look used by the live placement preview at the crosshair.
enum PlacementPreviewStyler {
    private static let ghostColor = UIColor(hex: 0x999999)
    private static let ghostOpacity: PhysicallyBasedMaterial.Opacity = 0.35

    static func applyGhostMaterial(to entity: Entity) {
        var ghostMaterial = UnlitMaterial(color: ghostColor)
        ghostMaterial.blending = .transparent(opacity: ghostOpacity)

        for modelEntity in modelEntities(in: entity) {
            let materialCount = max(modelEntity.model?.materials.count ?? 1, 1)
            modelEntity.model?.materials = Array(repeating: ghostMaterial, count: materialCount)
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
