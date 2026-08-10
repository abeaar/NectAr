import Foundation
import RealityKit
import ARKit

/// Drives the simulation phase: animates the mail packet only between placed devices
/// within the router's range, looping until stopped. See ``deadzoneHint`` and
/// ``currentLegHint`` for why a leg might be skipped or slowed.
@Observable
final class SimulationSceneController {
    private static let baseLegDuration: TimeInterval = 3
    private static let obstructedMultiplier: Double = 2.0

    weak var arView: ARView?
    private(set) var currentLegHint: String?
    /// Persistent for the whole simulation, unlike `currentLegHint`, since it
    /// describes a placement fact rather than something tied to the current leg.
    private(set) var deadzoneHint: String?
    private var animationTask: Task<Void, Never>?

    /// Starts or restarts the animation for the given placed topology, cancelling any
    /// animation already in progress.
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

        let attributes = RouterAttributes()
        guard attributes.isOn else {
            deadzoneHint = "The router is off and can't be reached"
            currentLegHint = nil
            animationTask = nil
            return
        }

        let deviceAInRange = RouterRangeChecker.isInRange(device: deviceA, router: router, range: attributes.range)
        let deviceBInRange = RouterRangeChecker.isInRange(device: deviceB, router: router, range: attributes.range)

        guard deviceAInRange || deviceBInRange else {
            deadzoneHint = "Both devices are outside the router's range and can't reach it"
            currentLegHint = nil
            animationTask = nil
            return
        }

        let planes = arView.session.currentFrame?.anchors.compactMap { $0 as? ARPlaneAnchor } ?? []

        let origin: simd_float4x4
        let waypoints: [simd_float4x4]
        let waypointsObstructed: [Bool]

        if deviceAInRange && deviceBInRange {
            origin = deviceA
            let deviceARouterObstructed = WallObstructionChecker.isObstructed(from: deviceA, to: router, planes: planes)
            let routerDeviceBObstructed = WallObstructionChecker.isObstructed(from: router, to: deviceB, planes: planes)
            waypoints = [router, deviceB, router, deviceA]
            waypointsObstructed = [deviceARouterObstructed, routerDeviceBObstructed, routerDeviceBObstructed, deviceARouterObstructed]
            deadzoneHint = nil
        } else if deviceAInRange {
            origin = deviceA
            let obstructed = WallObstructionChecker.isObstructed(from: deviceA, to: router, planes: planes)
            waypoints = [router, deviceA]
            waypointsObstructed = [obstructed, obstructed]
            deadzoneHint = "Device B is outside the router's range and can't send or receive data"
        } else {
            origin = deviceB
            let obstructed = WallObstructionChecker.isObstructed(from: router, to: deviceB, planes: planes)
            waypoints = [router, deviceB]
            waypointsObstructed = [obstructed, obstructed]
            deadzoneHint = "Device A is outside the router's range and can't send or receive data"
        }

        animationTask = Task {
            do {
                let mail = try await DeviceEntityLoader.loadMailPacket()
                let anchor = AnchoredEntityPlacer.place(mail, at: origin, in: arView.scene)
                defer { AnchoredEntityPlacer.remove(anchor, from: arView.scene) }

                // Keep the mail's orientation fixed instead of inheriting each
                // waypoint's surface rotation, so it doesn't spin as it travels.
                let fixedRotation = mail.transform.rotation

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
        deadzoneHint = nil
    }
}
