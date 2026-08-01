
import Foundation
import ARKit

protocol ARSessionManaging: AnyObject {
    var session: ARSession { get }
    var trackingFailureReason: TrackingFailureReason? { get }
    func start()
}
