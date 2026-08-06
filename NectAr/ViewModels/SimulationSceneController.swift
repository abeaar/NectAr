import Foundation
import RealityKit
import ARKit

/// Drives the simulation phase: animates the mail packet through
/// `deviceA → router → deviceB → router → deviceA`, looping until stopped.
///
/// Slows legs that cross a real detected wall (see ``WallObstructionChecker``) to
/// `baseLegDuration * obstructedMultiplier`, and surfaces `currentLegHint` so the UI
/// can explain why. Obstruction is computed once per ``startAnimating(topology:)``
/// call, not per-frame — the room doesn't change shape mid-simulation.
@Observable
final class SimulationSceneController {
    private static let baseLegDuration: TimeInterval = 3
    private static let obstructedMultiplier: Double = 2.0

    weak var arView: ARView?
    private(set) var currentLegHint: String?
    private var animationTask: Task<Void, Never>?

    /// Starts (or restarts) the looping A → Router → B → Router → A animation for the
    /// given placed topology. Cancels any animation already in progress.
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

        let planes = arView.session.currentFrame?.anchors.compactMap { $0 as? ARPlaneAnchor } ?? []
        let deviceARouterObstructed = WallObstructionChecker.isObstructed(from: deviceA, to: router, planes: planes)
        let routerDeviceBObstructed = WallObstructionChecker.isObstructed(from: router, to: deviceB, planes: planes)

        animationTask?.cancel()
        animationTask = Task {
            do {
                let mail = try await DeviceEntityLoader.loadMailPacket()
                let anchor = AnchoredEntityPlacer.place(mail, at: deviceA, in: arView.scene)
                defer { AnchoredEntityPlacer.remove(anchor, from: arView.scene) }

                // Keep the mail's orientation fixed instead of inheriting each
                // waypoint's surface rotation, so it doesn't spin as it travels.
                let fixedRotation = mail.transform.rotation

                let waypoints = [router, deviceB, router, deviceA]
                let waypointsObstructed = [deviceARouterObstructed, routerDeviceBObstructed, routerDeviceBObstructed, deviceARouterObstructed]

                while !Task.isCancelled {
                    for (waypoint, isObstructed) in zip(waypoints, waypointsObstructed) {
                        try Task.checkCancellation()
                        currentLegHint = isObstructed ? "Passing through wall — signal slowed" : nil

                        let legDuration = isObstructed
                            ? Self.baseLegDuration * Self.obstructedMultiplier
                            : Self.baseLegDuration

                        var targetTransform = Transform(matrix: waypoint)
                        targetTransform.rotation = fixedRotation
                        targetTransform.scale = mail.scale // Preserve custom scale during animation
                        mail.move(to: targetTransform, relativeTo: nil, duration: legDuration)
                        try await Task.sleep(nanoseconds: UInt64(legDuration * 1_000_000_000))
                    }
                }
            } catch {
                // Cancelled (user stopped the simulation) or failed to load - either way, stop quietly.
            }
        }
    }

    func stopAnimating() {
        animationTask?.cancel()
        animationTask = nil
        currentLegHint = nil
    }
}
