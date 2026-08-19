import Mail_3d
import SwiftUI
import RealityKit
import ARKit
import simd
import Bee

struct BeeMailPreview: View {
    @State private var entity: Entity?
    @State private var camera: PerspectiveCamera?

    var body: some View {
        RealityView { content in
            if entity == nil {
                let loaded = try? await Entity(named: "Bee", in: mail_3dBundle)
                loaded?.scale = SIMD3<Float>(repeating: 1)
                if let loaded {
                    content.add(loaded)
                    entity = loaded
                    placeWavy(loaded)
                }
                let cam = PerspectiveCamera()
                cam.position = SIMD3<Float>(0.5, 0.5, 0.5)
                cam.look(at: .zero, from: cam.position, relativeTo: nil)
                content.add(cam)
                camera = cam
            }
        }

    }

    private func placeWavy(_ entity: Entity) {
        let baseTransform = entity.transform
        Task {
            var t: Float = 0
            let freq: Float = 1.5
            let ampY: Float = 0.015
            let ampR: Float = 0.05
            while entity.parent != nil {
                let y = sin(t * freq * 2 * .pi) * ampY
                let rz = sin(t * freq * 2 * .pi) * ampR
                var tx = baseTransform
                tx.translation.y = baseTransform.translation.y + y
                tx.rotation = simd_quatf(angle: rz, axis: SIMD3<Float>(0, 0, 1))
                entity.move(to: tx, relativeTo: entity.parent, duration: 0.05, timingFunction: .easeInOut)
                try? await Task.sleep(nanoseconds: 16_666_666)
                t += 1.0 / 60.0
            }
        }
    }
}

#Preview {
    BeeMailPreview()
}
