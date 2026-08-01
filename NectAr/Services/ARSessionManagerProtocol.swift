
import Foundation
import ARKit

protocol ARSessionManagerProtocol: AnyObject {
    var session: ARSession { get }
    var trackingFailureReason: TrackingFailureReason? { get }
    func start()
}
