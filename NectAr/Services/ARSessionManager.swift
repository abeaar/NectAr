import ARKit

/// Owns the single `ARSession` for the app's lifetime and does nothing else — its only
/// job is translating ARKit's tracking-state delegate callbacks into
/// ``TrackingFailureReason``, which ``ARViewModel`` turns into user-facing hint text.
///
/// Detects both horizontal and vertical planes: horizontal for placing devices/router
/// on a table, vertical for wall-mounting the router (PRD G3) and, separately, for
/// ``WallObstructionChecker``'s wall-crossing test during simulation. No scene
/// reconstruction (LiDAR mesh) is enabled — obstruction detection relies on these flat
/// plane anchors, not real room geometry.
@Observable
final class ARSessionManager: NSObject, ARSessionManaging, ARSessionDelegate {
    let session = ARSession()
    var trackingFailureReason: TrackingFailureReason?
    /// Set when `session.run()` fails outright — e.g. camera permission denied. Distinct
    /// from `trackingFailureReason`, which only covers a *running* session's tracking
    /// quality; without this, a failed session left `hintText` stuck on "Move your
    /// device to find a surface" with no camera feed and no indication why.
    var sessionError: String?

    func start() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        session.delegate = self
        session.run(configuration)
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
