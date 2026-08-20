import Foundation
import RealityKit
import ARKit
import UIKit

/// Drives the simulation phase across its two loops. The first loop narrates and
/// animates the round trip as one non-interactive lockstep sequence (see
/// `runFullSequence`), ending in a quiz prompt on success. Declining it starts the
/// second loop (`loopMode == .manual`), where every sidebar card is individually
/// tappable and plays only its own leg's animation.
@Observable
final class SimulationSceneController {
    private static let baseLegDuration: TimeInterval = 4
    private static let obstructedMultiplier: Double = 2.0
    private static let minLegLookAtDistance: Float = 0.05
    /// How long a non-movement narration card holds before advancing, and how long
    /// a movement card holds before handing off to its wall card when obstructed.
    private static let phaseAnchorDuration: TimeInterval = 5
    /// How long the mail sits parked after a successful first loop before the quiz
    /// prompt appears.
    private static let quizPromptDelay: TimeInterval = 3
    /// How long the fatal range sphere holds at full opacity before it starts
    /// dissolving, and how long the dissolve itself takes.
    private static let fatalRangeSphereHoldDuration: TimeInterval = 1
    private static let fatalRangeSphereDissolveDuration: TimeInterval = 6
    private static let fatalRangeSphereFrameInterval: TimeInterval = 1.0 / 60.0
    private static let fatalRangeSphereOpacity: Float = 0.45
    private static let fatalRangeSphereColor = UIColor(red: 1.0, green: 0.2196, blue: 0.2353, alpha: 1) // #FF383C

    weak var arView: ARView?

    func attachARView(_ arView: ARView) {
        self.arView = arView
    }
    private(set) var selection: SimulationPlaybackSelection = .full
    /// Why the simulation can't deliver the message, nil means both devices
    /// are in range and it's playing normally.
    private(set) var failureReason: SimulationFailureReason?
    /// True once a leg has ever been found obstructed by a wall this run, sticky
    /// for the rest of the run rather than tied to whichever leg is currently playing.
    private(set) var sendToRouterObstructed: Bool = false
    private(set) var sendToTargetObstructed: Bool = false
    /// The card the sidebar should currently highlight, set explicitly at each stage
    /// of the full sequence's timeline rather than inferred from other state changing.
    private(set) var activeCardID: SimulationCardID?
    /// Whether the first loop's narrated sequence is still running, or the user has
    /// declined the quiz prompt and switched to tapping each card individually.
    private(set) var loopMode: SimulationLoopMode = .narrated
    /// True once the first loop finishes successfully and the quiz prompt should show.
    private(set) var isQuizPromptActive: Bool = false

    private var topology: PlacedTopology?
    private var currentPlan: RoundTripPlan?
    private var animationTask: Task<Void, Never>?
    private var phaseSequenceTask: Task<Void, Never>?
    private var fatalRangeSphereTask: Task<Void, Never>?
    /// The router's range sphere visibility as the preparation-phase debug
    /// toggle left it, captured once before simulation starts, restored by
    /// `stopAnimating`. No longer forced visible during simulation itself,
    /// only the fatal range sphere shows now, and only on a failure.
    private var rangeSphereVisibilityBeforeSimulation = false

    private struct RoundTripPlan {
        let deviceA: simd_float4x4
        let router: simd_float4x4
        let deviceB: simd_float4x4
        let deviceAInRange: Bool
        let deviceBInRange: Bool
        let routerRange: Float
    }

    /// Starts the full simulation loop for the placed topology, called once when
    /// the simulation phase begins.
    func startAnimating(topology: PlacedTopology) {
        self.topology = topology
        hideStandaloneMascot()
        if let arView, let routerEntity = entity(for: .router, in: arView) {
            rangeSphereVisibilityBeforeSimulation = routerEntity.components[RangeSphereVisibilityComponent.self]?.isVisible ?? false
        }
        sendToRouterObstructed = false
        sendToTargetObstructed = false
        activeCardID = nil
        loopMode = .narrated
        isQuizPromptActive = false
        select(.full)
        phaseSequenceTask = Task { [weak self] in
            await self?.runFullSequence()
        }
    }

    /// Called when the user declines the post-first-loop quiz prompt. Switches to
    /// the second loop, where every card is individually tappable and "Full
    /// Simulation" (replacing "Introduction") plays continuously by default.
    func declineSecondLoop() {
        phaseSequenceTask?.cancel()
        phaseSequenceTask = nil
        isQuizPromptActive = false
        loopMode = .manual
        select(.fullPreview)
        activeCardID = .fullSimulation
    }

    /// Switches playback to `selection`, called by the sidebar whenever the user
    /// taps a second-loop card, or by `declineSecondLoop` for the default "Full
    /// Simulation" preview. `.full` itself is only ever selected from
    /// `startAnimating`, its own timeline lives entirely in `runFullSequence`.
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
        fatalRangeSphereTask?.cancel()
        clearHighlights()

        let routerEntity = entity(for: .router, in: arView)
        let attributes = routerEntity?.components[RouterAttributesComponent.self]?.attributes ?? RouterAttributes()

        guard attributes.isOn else {
            failureReason = .routerOff
            animationTask = nil
            currentPlan = nil
            return
        }

        let deviceAInRange = SimulationRangeChecker.isInRange(device: deviceA, router: router, range: attributes.range)
        let deviceBInRange = SimulationRangeChecker.isInRange(device: deviceB, router: router, range: attributes.range)

        failureReason = (deviceAInRange && deviceBInRange)
            ? nil
            : (!deviceAInRange && !deviceBInRange ? .bothOutOfRange : .deviceOutOfRange(deviceAInRange ? .deviceB : .deviceA))

        let plan = RoundTripPlan(deviceA: deviceA, router: router, deviceB: deviceB, deviceAInRange: deviceAInRange, deviceBInRange: deviceBInRange, routerRange: attributes.range)
        currentPlan = plan

        switch selection {
        case .full:
            animationTask = nil // driven by `runFullSequence` instead
        case .fullPreview:
            animationTask = Task { [weak self] in
                await self?.runFullPreview(plan: plan, arView: arView)
            }
        case .step(let step):
            animationTask = Task { [weak self] in
                await self?.runStep(step, plan: plan, arView: arView)
            }
        case .wall(let leg):
            animationTask = Task { [weak self] in
                await self?.runWallStep(leg, plan: plan, arView: arView)
            }
        }
    }

    func stopAnimating() {
        phaseSequenceTask?.cancel()
        phaseSequenceTask = nil
        activeCardID = nil
        loopMode = .narrated
        isQuizPromptActive = false
        animationTask?.cancel()
        animationTask = nil
        fatalRangeSphereTask?.cancel()
        fatalRangeSphereTask = nil
        clearHighlights()
        failureReason = nil
        sendToRouterObstructed = false
        sendToTargetObstructed = false
        currentPlan = nil
        showStandaloneMascot()
        restoreRangeSphereVisibility()
    }

    // MARK: - Full sequence (narration + animation, one timeline)

    /// Walks the reachable step prefix (or all six on success) once, holding each
    /// narration card for its own duration and animating the mail packet exactly
    /// while its step is current. On success it then holds and offers the quiz
    /// prompt instead of looping again. On a failure it reveals the fatal range
    /// sphere and failure card, then the trailing "Unable to Send" card when one
    /// applies. Cancelled either way once the user answers the quiz prompt.
    private func runFullSequence() async {
        guard let plan = currentPlan, let arView else { return }
        let reason = failureReason
        let phases = reason?.reachablePhases ?? SimulationStepKind.allCases

        let planes = arView.session.currentFrame?.anchors.compactMap { $0 as? ARPlaneAnchor } ?? []
        if plan.deviceAInRange {
            sendToRouterObstructed = SimulationObstructionChecker.isObstructed(from: plan.deviceA, to: plan.router, planes: planes)
        }
        if plan.deviceAInRange, plan.deviceBInRange {
            sendToTargetObstructed = SimulationObstructionChecker.isObstructed(from: plan.router, to: plan.deviceB, planes: planes)
        }

        var mail: Entity?
        var mailAnchor: AnchorEntity?
        var currentTranslation = Transform(matrix: plan.deviceA).translation
        if plan.deviceAInRange, let loaded = try? await DeviceEntityLoader.loadMailPacket() {
            loaded.scale = SIMD3<Float>(repeating: 0.3)
            mailAnchor = AnchoredEntityPlacer.place(loaded, at: plan.deviceA, in: arView.scene)
            loaded.components.set(RouteComponent(waypoints: []))
            mail = loaded
        }
        defer {
            if let mailAnchor { AnchoredEntityPlacer.remove(mailAnchor, from: arView.scene) }
        }

        for step in phases {
            if Task.isCancelled { return }
            await runFullSequenceStep(step, plan: plan, mail: mail, currentTranslation: &currentTranslation, arView: arView)
        }
        if Task.isCancelled { return }

        guard let reason else {
            // Success: hold on the completed trip and offer the quiz instead of
            // looping again, keeping the mail visible until this task is cancelled.
            try? await Task.sleep(nanoseconds: UInt64(Self.quizPromptDelay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            isQuizPromptActive = true
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
            return
        }

        showFatalRangeSphere(on: entity(for: .router, in: arView), range: plan.routerRange)
        activeCardID = .failure
        guard reason.hasTerminalCard else { return }
        try? await Task.sleep(nanoseconds: UInt64(Self.phaseAnchorDuration * 1_000_000_000))
        guard !Task.isCancelled else { return }
        activeCardID = .terminal
    }

    /// Plays one card's worth of the full sequence: a plain hold for a
    /// narration-only step, a highlighted hold for "Router Reads The Address," or
    /// the mail's real travel for a reachable leg. A leg found obstructed holds its
    /// step card first with no animation, then hands off to its wall card for the
    /// (slower) actual travel.
    private func runFullSequenceStep(_ step: SimulationStepKind, plan: RoundTripPlan, mail: Entity?, currentTranslation: inout SIMD3<Float>, arView: ARView) async {
        switch step {
        case .introduction:
            activeCardID = .step(.introduction)
            await hold(duration: Self.phaseAnchorDuration)

        case .checkSender:
            activeCardID = .step(.checkSender)
            await hold(duration: Self.phaseAnchorDuration)

        case .checkTarget:
            activeCardID = .step(.checkTarget)
            await holdWithHighlight(kind: .deviceB, duration: Self.phaseAnchorDuration, arView: arView)

        case .sendToRouter:
            guard plan.deviceAInRange, let mail else { return }
            activeCardID = .step(.sendToRouter)
            if sendToRouterObstructed {
                try? await Task.sleep(nanoseconds: UInt64(Self.phaseAnchorDuration * 1_000_000_000))
                guard !Task.isCancelled else { return }
                activeCardID = .wall(.sendToRouter)
            }
            await moveMail(mail, to: plan.router, obstructed: sendToRouterObstructed, currentTranslation: &currentTranslation)

        case .sendToTarget:
            guard plan.deviceBInRange, let mail else { return }
            activeCardID = .step(.sendToTarget)
            if sendToTargetObstructed {
                try? await Task.sleep(nanoseconds: UInt64(Self.phaseAnchorDuration * 1_000_000_000))
                guard !Task.isCancelled else { return }
                activeCardID = .wall(.sendToTarget)
            }
            await moveMail(mail, to: plan.deviceB, obstructed: sendToTargetObstructed, currentTranslation: &currentTranslation)

        case .targetReceives:
            guard let mail else { return }
            activeCardID = .step(.targetReceives)
            // The return trip plays in one go, no dedicated wall card for either leg.
            await moveMail(mail, to: plan.router, obstructed: sendToTargetObstructed, currentTranslation: &currentTranslation)
            if !Task.isCancelled {
                await moveMail(mail, to: plan.deviceA, obstructed: sendToRouterObstructed, currentTranslation: &currentTranslation)
            }
        }
    }

    /// Holds this step's card active for exactly `duration`.
    private func hold(duration: TimeInterval) async {
        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
    }

    /// Pulses a highlight on the placed entity for `kind` for exactly `duration`.
    private func holdWithHighlight(kind: DeviceKind, duration: TimeInterval, arView: ARView) async {
        let target = entity(for: kind, in: arView)
        target?.components[HighlightComponent.self]?.isHighlighted = true
        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
        target?.components[HighlightComponent.self]?.isHighlighted = false
    }

    /// Animates the mail packet from wherever it currently sits to `waypoint` once,
    /// waiting for the move to finish before returning.
    private func moveMail(_ mail: Entity, to waypoint: simd_float4x4, obstructed: Bool, currentTranslation: inout SIMD3<Float>) async {
        let legDuration = obstructed ? Self.baseLegDuration * Self.obstructedMultiplier : Self.baseLegDuration
        let targetTranslation = Transform(matrix: waypoint).translation
        let targetRotation = simd_distance(currentTranslation, targetTranslation) > Self.minLegLookAtDistance
            ? MailFacing.rotation(from: currentTranslation, to: targetTranslation, up: SIMD3(0, 1, 0))
            : mail.transform.rotation

        var targetTransform = Transform(matrix: waypoint)
        targetTransform.rotation = targetRotation
        targetTransform.scale = mail.scale
        mail.move(to: targetTransform, relativeTo: nil, duration: legDuration, timingFunction: .easeInOut)

        currentTranslation = targetTranslation
        try? await Task.sleep(nanoseconds: UInt64(legDuration * 1_000_000_000))
    }

    // MARK: - Second loop: individual step and wall cards (always loop until reselected)

    /// Only reachable in the second loop, after a prior success, so both devices
    /// are always in range here. A leg found obstructed holds silent on tap, since
    /// its animation lives on the wall card (`runWallStep`) instead.
    private func runStep(_ step: SimulationStepKind, plan: RoundTripPlan, arView: ARView) async {
        switch step {
        case .introduction, .checkSender:
            await runIdleLoop()

        case .checkTarget:
            await runHighlightLoop(kind: .deviceB, arView: arView)

        case .sendToRouter:
            guard !sendToRouterObstructed else { await runIdleLoop(); return }
            await runMailLoop(origin: plan.deviceA, waypoints: [plan.router], waypointsObstructed: [false], arView: arView, loopsForever: true)

        case .sendToTarget:
            guard !sendToTargetObstructed else { await runIdleLoop(); return }
            await runMailLoop(origin: plan.router, waypoints: [plan.deviceB], waypointsObstructed: [false], arView: arView, loopsForever: true)

        case .targetReceives:
            await runMailLoop(origin: plan.deviceB, waypoints: [plan.router, plan.deviceA], waypointsObstructed: [sendToTargetObstructed, sendToRouterObstructed], arView: arView, loopsForever: true)
        }
    }

    /// Plays the (always obstructed) travel animation for `leg`'s wall card.
    private func runWallStep(_ leg: SimulationStepKind, plan: RoundTripPlan, arView: ARView) async {
        switch leg {
        case .sendToRouter:
            await runMailLoop(origin: plan.deviceA, waypoints: [plan.router], waypointsObstructed: [true], arView: arView, loopsForever: true)
        case .sendToTarget:
            await runMailLoop(origin: plan.router, waypoints: [plan.deviceB], waypointsObstructed: [true], arView: arView, loopsForever: true)
        default:
            return
        }
    }

    /// Loops the entire round trip continuously, the second loop's default "Full
    /// Simulation" card. Only reachable after a prior success, so both devices are
    /// always in range here.
    private func runFullPreview(plan: RoundTripPlan, arView: ARView) async {
        let waypoints = [plan.router, plan.deviceB, plan.router, plan.deviceA]
        let waypointsObstructed = [sendToRouterObstructed, sendToTargetObstructed, sendToTargetObstructed, sendToRouterObstructed]
        await runMailLoop(origin: plan.deviceA, waypoints: waypoints, waypointsObstructed: waypointsObstructed, arView: arView, loopsForever: true)
    }

    /// Idles until this task is cancelled, while this step's card is being previewed.
    private func runIdleLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 500_000_000)
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

    /// Animates the mail packet from `origin` through `waypoints`. When
    /// `loopsForever` is true it jumps back to `origin` and replays the same leg
    /// until cancelled, matching a successful round trip. When false it plays once
    /// and stays parked at the final waypoint, since the sequence itself has ended.
    private func runMailLoop(origin: simd_float4x4, waypoints: [simd_float4x4], waypointsObstructed: [Bool], arView: ARView, loopsForever: Bool) async {
        do {
            let mail = try await DeviceEntityLoader.loadMailPacket()
            mail.scale = SIMD3<Float>(repeating: 0.3)
            let anchor = AnchoredEntityPlacer.place(mail, at: origin, in: arView.scene)
            defer { AnchoredEntityPlacer.remove(anchor, from: arView.scene) }
            mail.components.set(RouteComponent(waypoints: waypoints))

            // Track the last-known translation so the next leg's look-at starts from
            // where the mail actually is, not from a static origin reference.
            var currentTranslation = Transform(matrix: origin).translation

            repeat {
                for (index, (waypoint, isObstructed)) in zip(waypoints, waypointsObstructed).enumerated() {
                    try Task.checkCancellation()
                    mail.components[RouteComponent.self]?.currentIndex = index

                    let legDuration = isObstructed
                        ? Self.baseLegDuration * Self.obstructedMultiplier
                        : Self.baseLegDuration

                    let targetTranslation = Transform(matrix: waypoint).translation
                    // Skip the rotation recompute on tiny legs so the mail doesn't
                    // snap direction between bouncing back to the origin.
                    let targetRotation = simd_distance(currentTranslation, targetTranslation) > Self.minLegLookAtDistance
                        ? MailFacing.rotation(from: currentTranslation, to: targetTranslation, up: SIMD3(0, 1, 0))
                        : mail.transform.rotation

                    var targetTransform = Transform(matrix: waypoint)
                    targetTransform.rotation = targetRotation
                    targetTransform.scale = mail.scale // Preserve custom scale during animation
                    mail.move(to: targetTransform, relativeTo: nil, duration: legDuration, timingFunction: .easeInOut)

                    currentTranslation = targetTranslation
                    try await Task.sleep(nanoseconds: UInt64(legDuration * 1_000_000_000))
                }

                guard loopsForever else { break }
                try Task.checkCancellation()
                mail.transform.translation = Transform(matrix: origin).translation
                currentTranslation = Transform(matrix: origin).translation
            } while !Task.isCancelled

            if !loopsForever {
                // Stay parked at the final waypoint until the next selection cancels this task.
                while !Task.isCancelled {
                    try await Task.sleep(nanoseconds: 500_000_000)
                }
            }
        } catch {
            // Cancelled (selection changed or simulation exited) or failed to load, stop quietly.
        }
    }

    private func showFatalRangeSphere(on routerEntity: Entity?, range: Float) {
        guard let routerEntity else { return }
        fatalRangeSphereTask = Task { [weak self] in
            await self?.presentFatalRangeSphere(on: routerEntity, range: range)
        }
    }

    /// Flashes a bold, translucent sphere over the router's real WiFi range then
    /// dissolves it away, the visual cue for why the message can't be delivered.
    /// Separate from `RangeVisualizationSystem`'s reactive `"RangeSphere"` child, this
    /// is a one-shot animated sequence tied to a specific state transition, not a
    /// continuous per-frame rebuild.
    private func presentFatalRangeSphere(on routerEntity: Entity, range: Float) async {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: Self.fatalRangeSphereColor, texture: nil)
        material.roughness = .init(floatLiteral: 1.0)
        material.metallic = .init(floatLiteral: 0.0)
        material.faceCulling = .none
        material.blending = .transparent(opacity: .init(floatLiteral: Self.fatalRangeSphereOpacity))

        let sphere = ModelEntity(mesh: .generateSphere(radius: range), materials: [material])
        sphere.name = "FatalRangeSphere"
        sphere.components.set(OpacityComponent(opacity: 1))
        routerEntity.addChild(sphere)
        defer { sphere.removeFromParent() }

        do {
            try await Task.sleep(nanoseconds: UInt64(Self.fatalRangeSphereHoldDuration * 1_000_000_000))

            let startTime = Date()
            while true {
                try Task.checkCancellation()
                let elapsed = Date().timeIntervalSince(startTime)
                let t = min(Float(elapsed / Self.fatalRangeSphereDissolveDuration), 1)
                sphere.components[OpacityComponent.self]?.opacity = 1 - t
                if t >= 1 { break }
                try await Task.sleep(nanoseconds: UInt64(Self.fatalRangeSphereFrameInterval * 1_000_000_000))
            }
        } catch {
            // Cancelled (selection changed or simulation exited), stop quietly.
        }
    }

    /// Undoes `select`'s forced-visible range sphere, restoring whatever the
    /// preparation-phase debug toggle had it set to before simulation started.
    private func restoreRangeSphereVisibility() {
        guard let arView, let routerEntity = entity(for: .router, in: arView) else { return }
        routerEntity.components[RangeSphereVisibilityComponent.self]?.isVisible = rangeSphereVisibilityBeforeSimulation
    }

    // MARK: - Scene lookups

    private func entity(for kind: DeviceKind, in arView: ARView) -> Entity? {
        let query = EntityQuery(where: .has(DeviceIdentityComponent.self))
        return Array(arView.scene.performQuery(query)).first { $0.components[DeviceIdentityComponent.self]?.kind == kind }
    }

    // Despawns the standalone mascot bee anchor while simulation is running, so
    // only the bee nested inside the mail packet is visible. The anchor is
    // saved so it can be re-added when the user leaves simulation.
    private var storedMascotAnchor: AnchorEntity?

    private func hideStandaloneMascot() {
        guard let arView else { return }
        let mascotQuery = EntityQuery(where: .has(MascotStateComponent.self))
        guard let mascot = Array(arView.scene.performQuery(mascotQuery)).first,
              let anchor = mascot.parent as? AnchorEntity else { return }
        storedMascotAnchor = anchor
        arView.scene.removeAnchor(anchor)
    }

    /// Re-spawns the standalone mascot bee anchor, called when the user leaves
    /// the simulation phase and returns to preparation.
    func showStandaloneMascot() {
        guard let arView, let anchor = storedMascotAnchor else { return }
        arView.scene.addAnchor(anchor)
        storedMascotAnchor = nil
    }

    private func clearHighlights() {
        guard let arView else { return }
        let query = EntityQuery(where: .has(HighlightComponent.self))
        for entity in arView.scene.performQuery(query) {
            entity.components[HighlightComponent.self]?.isHighlighted = false
        }
    }
}
