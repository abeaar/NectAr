import Foundation
import RealityKit
import ARKit

/// Drives the preparation phase: raycasts from the screen center against detected
/// planes, and anchors the selected ``DeviceKind``'s entity at the hit point.
///
/// Holds `arView` weakly because it's injected by `ARContainerView`
/// (`UIViewRepresentable.makeUIView`), which owns the actual `ARView`'s lifetime.
@Observable
final class PlacementSceneController {
    var selectedDeviceKind: DeviceKind = .deviceA
    private(set) var placedTransforms: [DeviceKind: simd_float4x4] = [:]
    weak var arView: ARView?
    private var placedAnchors: [DeviceKind: AnchorEntity] = [:]

    var placedKinds: Set<DeviceKind> {
        Set(placedTransforms.keys)
    }

    var isComplete: Bool {
        placedKinds.count == DeviceKind.allCases.count
    }

    func canPlace(_ kind: DeviceKind) -> Bool {
        !placedKinds.contains(kind)
    }

    func confirmPlacement() {
        guard let arView else {
            print("AR view not ready yet")
            return
        }
        
        let kind = selectedDeviceKind
        guard canPlace(kind) else {
            print("\(kind.label) has already been placed")
            return
        }

        let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        let results = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any)

        guard let firstResult = results.first else {
            print("No surface found at crosshair")
            return
        }

        Task {
            do {
                let entity = try await DeviceEntityLoader.load(kind)
                let anchor = AnchoredEntityPlacer.place(entity, at: firstResult.worldTransform, in: arView.scene)
                placedAnchors[kind] = anchor
                placedTransforms[kind] = firstResult.worldTransform
            } catch {
                print("Failed to load \(kind) entity: \(error)")
            }
        }
    }

    func reset() {
        guard let arView else { return }

        for (_, anchor) in placedAnchors {
            AnchoredEntityPlacer.remove(anchor, from: arView.scene)
        }
        placedAnchors.removeAll()
        placedTransforms.removeAll()
    }
}
