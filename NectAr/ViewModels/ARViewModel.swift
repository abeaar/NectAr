//
//  NectAr
//
//  Created by abr on 01/08/26.
//
import ARKit
import RealityKit
import Foundation

@Observable
final class ARViewModel<Manager: ARSessionManaging> {

    private let sessionManager: Manager
    let arView: ARView

    init(sessionManager: Manager) {
        self.sessionManager = sessionManager
        self.arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        self.arView.session = sessionManager.session
    }


    var hintText: String {
        if let sessionError = sessionManager.sessionError {
            return sessionError
        }
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
        }
    }

    func start() {
        sessionManager.start()
    }

    func pause() {
        sessionManager.pause()
    }
}

extension ARViewModel where Manager == ARSessionManager {
    convenience init() {
        self.init(sessionManager: ARSessionManager())
    }
}
