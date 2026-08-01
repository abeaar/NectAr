import ARKit
import Combine

final class ARSessionManager: NSObject, ObservableObject, ARSessionDelegate {
    let session = ARSession()
    var trackingFailureReason: TrackingFailureReason?

    func start() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        session.delegate = self
        session.run(configuration)
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
