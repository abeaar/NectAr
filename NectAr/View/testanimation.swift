//
//  testanimation.swift
//  NectAr
//
//  Debug-only view that drives the real `SimulationSceneController` against a
//  fake ARView, no AR session, no placement, no onboarding. Lets you watch the
//  bee-mail wave and route in isolation. Open with the Xcode preview canvas.
//

import SwiftUI
import RealityKit
import ARKit
import simd

struct TestAnimationView: View {
    private let arView = ARView(frame: .zero)
    @State private var simulationController = SimulationSceneController()
    @State private var legIndex = 0
    @State private var topology: PlacedTopology

    init() {
        let deviceA = Transform(translation: SIMD3<Float>(-0.4, 0, -0.2)).matrix
        let router  = Transform(translation: SIMD3<Float>( 0.0, 0,  0.0)).matrix
        let deviceB = Transform(translation: SIMD3<Float>( 0.4, 0, -0.2)).matrix
        _topology = State(initialValue: PlacedTopology(transforms: [.deviceA: deviceA, .router: router, .deviceB: deviceB]))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(arView: arView)
                .ignoresSafeArea()
            controlBar
                .padding()
        }
        .task {
            await setupScene()
            simulationController.attachARView(arView)
            simulationController.startAnimating(topology: topology)
        }
    }

    @ViewBuilder
    private var controlBar: some View {
        HStack(spacing: 12) {
            Button("Restart") {
                simulationController.stopAnimating()
                simulationController.startAnimating(topology: topology)
            }
            Button("Next Leg") {
                simulationController.stopAnimating()
                legIndex = (legIndex + 1) % 4
                simulationController.select(.step(legStep(for: legIndex)))
            }
            Spacer()
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func legStep(for index: Int) -> SimulationStepKind {
        switch index {
        case 0: .sendToRouter
        case 1: .sendToTarget
        case 2: .sendToRouter
        default: .sendToTarget
        }
    }

    private func setupScene() async {
        arView.cameraMode = .nonAR
        arView.environment.background = .color(.black)
        arView.environment.lighting.intensityExponent = 1.0

        for (kind, position) in [
            (DeviceKind.deviceA, SIMD3<Float>(-0.4, 0, -0.2)),
            (DeviceKind.router,  SIMD3<Float>( 0.0, 0,  0.0)),
            (DeviceKind.deviceB, SIMD3<Float>( 0.4, 0, -0.2))
        ] {
            let mesh = MeshResource.generateBox(size: 0.12)
            let color: UIColor = kind == .router ? .systemGreen : (kind == .deviceA ? .systemBlue : .systemOrange)
            let entity = ModelEntity(mesh: mesh, materials: [SimpleMaterial(color: color, isMetallic: false)])
            entity.position = position
            entity.components.set(DeviceIdentityComponent(kind: kind))
            if kind == .router {
                entity.components.set(RouterAttributesComponent(attributes: RouterAttributes(isOn: true, range: 5)))
                entity.components.set(RangeSphereVisibilityComponent(isVisible: false))
            }
            let anchor = AnchorEntity(world: position)
            anchor.addChild(entity)
            arView.scene.addAnchor(anchor)
        }

        do {
            let bee = try await DeviceEntityLoader.loadMascot()
            bee.scale = SIMD3<Float>(repeating: MascotOnboardingController.beeScale)
            bee.components.set(MascotStateComponent(phase: .complete))
            let beeAnchor = AnchorEntity(world: .zero)
            beeAnchor.addChild(bee)
            arView.scene.addAnchor(beeAnchor)
        } catch {
            print("Failed to load mascot: \(error)")
        }
    }
}

private struct ARViewContainer: UIViewRepresentable {
    let arView: ARView

    func makeUIView(context: Context) -> ARView { arView }
    func updateUIView(_ uiView: ARView, context: Context) {}
}

#Preview {
    TestAnimationView()
}