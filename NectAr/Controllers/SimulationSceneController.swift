import Foundation
import RealityKit
import ARKit

/// Drives the simulation phase, playing either the full round trip on loop or a
/// single sidebar step in isolation. See ``deadzoneHint``/``stepStatusText``.
@Observable
final class SimulationSceneController {
    private static let baseLegDuration: TimeInterval = 3
    private static let obstructedMultiplier: Double = 2.0
    private static let mascotTrailOffset = SIMD3<Float>(-0.1, 0.15, 0.15)

    weak var arView: ARView?

    func attachARView(_ arView: ARView) {
        self.arView = arView
    }
    private(set) var selection: SimulationPlaybackSelection = .full
    /// Persistent for the whole simulation, unlike `stepStatusText`, since it
    /// describes a placement fact rather than the currently selected step.
    private(set) var deadzoneHint: String?
    /// Explains what the currently selected step is doing right now, a wall
    /// slowing a leg or a device being out of range.
    private(set) var stepStatusText: String?

    private var topology: PlacedTopology?
    private var animationTask: Task<Void, Never>?

    private struct RoundTripPlan {
        let deviceA: simd_float4x4
        let router: simd_float4x4
        let deviceB: simd_float4x4
        let deviceAInRange: Bool
        let deviceBInRange: Bool
    }

    /// Starts the full simulation loop for the placed topology, called once when
    /// the simulation phase begins.
    func startAnimating(topology: PlacedTopology) {
        self.topology = topology
        select(.full)
    }

    /// Switches playback to `selection`, called by the sidebar whenever the user
    /// picks "Full Simulation" or one of the individual step cards.
    func select(_ selection: SimulationPlaybackSelection) {
        guard let arView, let topology else {
            print("Simulation not ready yet")
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

        self.selection = selection
        animationTask?.cancel()
        clearHighlights()
        stepStatusText = nil

        let routerEntity = entity(for: .router, in: arView)
        // The range sphere stays visible for the whole simulation regardless of the
        // preparation-phase debug toggle it was last left at.
        routerEntity?.components[RangeSphereVisibilityComponent.self]?.isVisible = true
        let attributes = routerEntity?.components[RouterAttributesComponent.self]?.attributes ?? RouterAttributes()

        guard attributes.isOn else {
            deadzoneHint = "The router is off and can't be reached"
            animationTask = nil
            return
        }

        let plan = RoundTripPlan(
            deviceA: deviceA,
            router: router,
            deviceB: deviceB,
            deviceAInRange: SimulationRangeChecker.isInRange(device: deviceA, router: router, range: attributes.range),
            deviceBInRange: SimulationRangeChecker.isInRange(device: deviceB, router: router, range: attributes.range)
        )

        guard plan.deviceAInRange || plan.deviceBInRange else {
            deadzoneHint = "Both devices are outside the router's range and can't reach it"
            animationTask = nil
            return
        }
        deadzoneHint = plan.deviceAInRange && plan.deviceBInRange ? nil
            : plan.deviceAInRange ? "Device B is outside the router's range and can't send or receive data"
            : "Device A is outside the router's range and can't send or receive data"

        switch selection {
        case .full:
            animationTask = Task { [weak self] in
                await self?.runFullLoop(plan: plan, arView: arView)
            }
        case .step(let step):
            animationTask = Task { [weak self] in
                await self?.runStep(step, plan: plan, arView: arView)
            }
        }
    }

    func stopAnimating() {
        animationTask?.cancel()
        animationTask = nil
        clearHighlights()
        deadzoneHint = nil
        stepStatusText = nil
    }

    // MARK: - Full round trip

    private func runFullLoop(plan: RoundTripPlan, arView: ARView) async {
        let planes = arView.session.currentFrame?.anchors.compactMap { $0 as? ARPlaneAnchor } ?? []

        let origin: simd_float4x4
        let waypoints: [simd_float4x4]
        let waypointsObstructed: [Bool]

        if plan.deviceAInRange && plan.deviceBInRange {
            origin = plan.deviceA
            let aToRouter = SimulationObstructionChecker.isObstructed(from: plan.deviceA, to: plan.router, planes: planes)
            let routerToB = SimulationObstructionChecker.isObstructed(from: plan.router, to: plan.deviceB, planes: planes)
            waypoints = [plan.router, plan.deviceB, plan.router, plan.deviceA]
            waypointsObstructed = [aToRouter, routerToB, routerToB, aToRouter]
        } else if plan.deviceAInRange {
            origin = plan.deviceA
            let obstructed = SimulationObstructionChecker.isObstructed(from: plan.deviceA, to: plan.router, planes: planes)
            waypoints = [plan.router, plan.deviceA]
            waypointsObstructed = [obstructed, obstructed]
        } else {
            origin = plan.deviceB
            let obstructed = SimulationObstructionChecker.isObstructed(from: plan.router, to: plan.deviceB, planes: planes)
            waypoints = [plan.router, plan.deviceB]
            waypointsObstructed = [obstructed, obstructed]
        }

        await guideMascotWhileRunning(in: arView) {
            await self.runMailLoop(origin: origin, waypoints: waypoints, waypointsObstructed: waypointsObstructed, arView: arView)
        }
    }

    // MARK: - Single step

    private func runStep(_ step: SimulationStepKind, plan: RoundTripPlan, arView: ARView) async {
        switch step {
        case .checkSender:
            stepStatusText = plan.deviceAInRange
                ? "Device A is inside the router's WiFi zone"
                : "Device A is outside the router's WiFi zone"
            await runHighlightLoop(kind: .deviceA, arView: arView)

        case .checkTarget:
            stepStatusText = plan.deviceBInRange
                ? "Device B is inside the router's WiFi zone"
                : "Device B is outside the router's WiFi zone"
            await runHighlightLoop(kind: .deviceB, arView: arView)

        case .targetReceives:
            stepStatusText = plan.deviceBInRange
                ? nil : "Device B never received the message, it's outside the router's range"
            await runHighlightLoop(kind: .deviceB, arView: arView)

        case .sendToRouter:
            guard plan.deviceAInRange else {
                stepStatusText = "Device A is outside the router's range and can't send"
                return
            }
            let planes = arView.session.currentFrame?.anchors.compactMap { $0 as? ARPlaneAnchor } ?? []
            let obstructed = SimulationObstructionChecker.isObstructed(from: plan.deviceA, to: plan.router, planes: planes)
            await guideMascotWhileRunning(in: arView) {
                await self.runMailLoop(origin: plan.deviceA, waypoints: [plan.router], waypointsObstructed: [obstructed], arView: arView)
            }

        case .sendToTarget:
            guard plan.deviceBInRange else {
                stepStatusText = "Device B is outside the router's range and can't receive"
                return
            }
            let planes = arView.session.currentFrame?.anchors.compactMap { $0 as? ARPlaneAnchor } ?? []
            let obstructed = SimulationObstructionChecker.isObstructed(from: plan.router, to: plan.deviceB, planes: planes)
            await guideMascotWhileRunning(in: arView) {
                await self.runMailLoop(origin: plan.router, waypoints: [plan.deviceB], waypointsObstructed: [obstructed], arView: arView)
            }
        }
    }

    /// Pulses a highlight on the placed entity for `kind` until this task is cancelled.
    private func runHighlightLoop(kind: DeviceKind, arView: ARView) async {
        guard let target = entity(for: kind, in: arView) else { return }
        target.components[HighlightComponent.self]?.isHighlighted = true
        defer { target.components[HighlightComponent.self]?.isHighlighted = false }

        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 500_000_000)
        }
    }

    /// Repeatedly animates the mail packet from `origin` through `waypoints`,
    /// jumping back to `origin` so the same leg replays until cancelled.
    private func runMailLoop(origin: simd_float4x4, waypoints: [simd_float4x4], waypointsObstructed: [Bool], arView: ARView) async {
        do {
            let mail = try await DeviceEntityLoader.loadMailPacket()
            let anchor = AnchoredEntityPlacer.place(mail, at: origin, in: arView.scene)
            defer { AnchoredEntityPlacer.remove(anchor, from: arView.scene) }
            mail.components.set(RouteComponent(waypoints: waypoints))

            // Keep the mail's orientation fixed instead of inheriting each
            // waypoint's surface rotation, so it doesn't spin as it travels.
            let fixedRotation = mail.transform.rotation

            while !Task.isCancelled {
                for (index, (waypoint, isObstructed)) in zip(waypoints, waypointsObstructed).enumerated() {
                    try Task.checkCancellation()
                    mail.components[RouteComponent.self]?.currentIndex = index
                    stepStatusText = isObstructed ? "Passing through wall, signal slowed" : nil

                    let legDuration = isObstructed
                        ? Self.baseLegDuration * Self.obstructedMultiplier
                        : Self.baseLegDuration

                    var targetTransform = Transform(matrix: waypoint)
                    targetTransform.rotation = fixedRotation
                    targetTransform.scale = mail.scale // Preserve custom scale during animation
                    mail.move(to: targetTransform, relativeTo: nil, duration: legDuration)
                    try await Task.sleep(nanoseconds: UInt64(legDuration * 1_000_000_000))
                }

                try Task.checkCancellation()
                mail.transform.translation = Transform(matrix: origin).translation
            }
        } catch {
            // Cancelled (selection changed or simulation exited) or failed to load, stop quietly.
        }
    }

    /// Marks the mascot as guiding for the duration of `body`, so `MascotFollowSystem`
    /// trails it behind the mail packet only while a movement step is actually playing.
    private func guideMascotWhileRunning(in arView: ARView, _ body: () async -> Void) async {
        let mascotQuery = EntityQuery(where: .has(MascotStateComponent.self))
        let mascot = Array(arView.scene.performQuery(mascotQuery)).first
        // The onboarding sequence leaves the bee disabled, shrunk, and faded out after
        // flying into the camera, undo all three now that it's guiding again.
        mascot?.isEnabled = true
        mascot?.scale = SIMD3<Float>(repeating: MascotOnboardingController.beeScale)
        mascot?.components[OpacityComponent.self]?.opacity = 1
        mascot?.components[MascotMovementComponent.self]?.pattern = .followOffset(Self.mascotTrailOffset)
        mascot?.components[MascotStateComponent.self]?.phase = .guiding

        await body()
    }

    // MARK: - Scene lookups

    private func entity(for kind: DeviceKind, in arView: ARView) -> Entity? {
        let query = EntityQuery(where: .has(DeviceIdentityComponent.self))
        return Array(arView.scene.performQuery(query)).first { $0.components[DeviceIdentityComponent.self]?.kind == kind }
    }

    private func clearHighlights() {
        guard let arView else { return }
        let query = EntityQuery(where: .has(HighlightComponent.self))
        for entity in arView.scene.performQuery(query) {
            entity.components[HighlightComponent.self]?.isHighlighted = false
        }
    }
}
