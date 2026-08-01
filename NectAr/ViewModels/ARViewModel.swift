//
//  NectAr
//
//  Created by abr on 01/08/26.
//
import ARKit
import Foundation

@Observable
final class ARViewModel<Manager: ARSessionManaging> {

    private let sessionManager: Manager
    init(sessionManager: Manager) {
        self.sessionManager = sessionManager
    }
    var arSession: ARSession {
        sessionManager.session
    }
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
