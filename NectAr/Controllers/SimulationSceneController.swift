import Foundation
import RealityKit
import ARKit

@Observable
final class SimulationSceneController: ARSceneDriven {
    private static let baseLegDuration: TimeInterval = 3
    private static let obstructedMultiplier: Double = 2.0

    weak var arView: ARView?
    private(set) var currentLegHint: String?
    private(set) var deadzoneHint: String?
    private var animationTask: Task<Void, Never>?

    func startAnimating(topology: PlacedTopology) {
        guard let arView else {
            print("AR view not ready yet")
            return
        }

        guard
            let deviceA = topology.transforms[.deviceA],
            let router = topology.transforms[.router],
            let deviceB = topology.transforms[.deviceB]
        else {
            print("Topology incomplete, cannot animate")
            return
        }

        animationTask?.cancel()
        animationTask = nil
        currentLegHint = nil

        let planes = arView.session.currentFrame?.anchors.compactMap { $0 as? ARPlaneAnchor } ?? []
        let resolution = SimulationRouteResolver.resolve(
            deviceA: deviceA,
            router: router,
            deviceB: deviceB,
            attributes: RouterAttributes(),
            planes: planes
        )

        switch resolution {
        case .blocked(let reason):
            deadzoneHint = reason
        case .runnable(let route):
            deadzoneHint = route.deadzoneHint
            animationTask = makeAnimationTask(for: route, in: arView)
        }
    }

    func stopAnimating() {
        animationTask?.cancel()
        animationTask = nil
        currentLegHint = nil
        deadzoneHint = nil
    }

    // MARK: - Animation

    private func makeAnimationTask(for route: SimulationRouteResolver.Route, in arView: ARView) -> Task<Void, Never> {
        Task {
            do {
                let mail = try await DeviceEntityLoader.loadMailPacket()
                let anchor = AnchoredEntityPlacer.place(mail, at: route.origin, in: arView.scene)
                defer { AnchoredEntityPlacer.remove(anchor, from: arView.scene) }

                // Keep the mail's orientation fixed instead of inheriting each
                // waypoint's surface rotation, so it doesn't spin as it travels.
                let fixedRotation = mail.transform.rotation

                while !Task.isCancelled {
                    for leg in route.legs {
                        try Task.checkCancellation()
                        try await travel(mail, along: leg, facing: fixedRotation)
                    }
                }
            } catch {
                // Cancelled (user stopped the simulation) or failed to load - either way, stop quietly.
            }
        }
    }

    private func travel(_ mail: Entity, along leg: SimulationRouteResolver.Leg, facing rotation: simd_quatf) async throws {
        currentLegHint = leg.isObstructed ? "Passing through wall — signal slowed" : nil

        let legDuration = leg.isObstructed
            ? Self.baseLegDuration * Self.obstructedMultiplier
            : Self.baseLegDuration

        var targetTransform = Transform(matrix: leg.destination)
        targetTransform.rotation = rotation
        targetTransform.scale = mail.scale // Transform(matrix:) would overwrite the load-time scale
        mail.move(to: targetTransform, relativeTo: nil, duration: legDuration)
        try await Task.sleep(nanoseconds: UInt64(legDuration * 1_000_000_000))
    }
}
