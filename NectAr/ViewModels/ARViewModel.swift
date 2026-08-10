//
//  NectAr
//
//  Created by abr on 01/08/26.
//
import ARKit
import RealityKit
import Foundation

/// Wraps an ``ARSessionManaging`` conformer and exposes AR tracking state as
/// presentation-ready `hintText`. Owns the single `ARView` shared by both the
/// placement and simulation phases.
///
/// Generic over the protocol (rather than concretely typed to ``ARSessionManager``)
/// purely to honor PRD goal G5 — a fake conformer could be substituted for previews
/// without touching a real `ARSession`. In practice, only `ARViewModel<ARSessionManager>`
/// is ever instantiated (see the `Manager == ARSessionManager` convenience `init()`
/// below).
@Observable
final class ARViewModel<Manager: ARSessionManaging> {

    private let sessionManager: Manager
    let arView: ARView

    init(sessionManager: Manager) {
        self.sessionManager = sessionManager
        self.arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        self.arView.session = sessionManager.session
    }

    var arSession: ARSession {
        sessionManager.session
    }

    /// User-facing hint derived from the session's current tracking-failure reason —
    /// e.g. "Move your device to find a surface" while no plane has been found yet.
    var hintText: String {
        switch sessionManager.trackingFailureReason {
        case .none:
            return "Move your device to find a surface"
        case .initializing:
            return "Hold still, starting up..."
        case .excessiveMotion:
            return "Slow down, moving too fast"
        case .insufficientFeatures:
            return "Point at a surface with more detail or light"
        case .relocalizing:
            return "Recovering tracking, move slowly"
        case .noPlaneYet:
            return "Move your device to find a surface"
        }
    }

    func start() {
        sessionManager.start()
    }
}

extension ARViewModel where Manager == ARSessionManager {
    convenience init() {
        self.init(sessionManager: ARSessionManager())
    }
}
