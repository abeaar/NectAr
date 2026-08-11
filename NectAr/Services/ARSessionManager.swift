import ARKit

@Observable
final class ARSessionManager: NSObject, ARSessionManaging, ARSessionDelegate {
    let session = ARSession()
    var trackingFailureReason: TrackingFailureReason?
    var sessionError: String?

    func start() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        session.delegate = self
        session.run(configuration)
    }

    func pause() {
        session.pause()
        trackingFailureReason = nil
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        print("ARSession failed: \(error)")
        if let arError = error as? ARError, arError.code == .cameraUnauthorized {
            sessionError = "Camera access is required. Enable it in Settings > NectAr > Camera."
        } else {
            sessionError = error.localizedDescription
        }
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .normal:
            trackingFailureReason = nil
        case .notAvailable:
            trackingFailureReason = .initializing
            
        case .limited(let reason):
            switch reason {
            case .initializing:
                trackingFailureReason = .initializing
            case .excessiveMotion:
                trackingFailureReason = .excessiveMotion
            case .insufficientFeatures:
                trackingFailureReason = .insufficientFeatures
            case .relocalizing:
                trackingFailureReason = .relocalizing
            @unknown default:
                trackingFailureReason = .initializing
            }
        }
    }
}
