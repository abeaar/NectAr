
import Foundation
import ARKit

/// Seam between the AR layer and the rest of the app (PRD goal G5).
///
/// Everything that touches ARKit directly should be reachable only through this
/// protocol, so view models can be faked in previews/tests without a real
/// `ARSession`. ``ARSessionManager`` is the only production conformer.
protocol ARSessionManaging: AnyObject {
    var session: ARSession { get }
    var trackingFailureReason: TrackingFailureReason? { get }
    var sessionError: String? { get }
    func start()
}
