import Foundation

/// Why the simulation can't deliver the message. `nil` on the controller means
/// success.
enum SimulationFailureReason: Equatable {
    case routerOff
    case deviceOutOfRange(DeviceKind)
    case bothOutOfRange

    var title: String {
        switch self {
        case .routerOff:
            return "The Router is Off!"
        case .deviceOutOfRange(let kind):
            return "\(kind.label) is Out of Range!"
        case .bothOutOfRange:
            return "Both Devices are Out of Range!"
        }
    }

    var description: String {
        switch self {
        case .routerOff:
            return "Turn the router back on so it can send WiFi signal to your devices."
        case .deviceOutOfRange(let kind):
            return "The \(kind.label) is too far from the router's WiFi zone. Go back to preparation and move it closer, then try again!"
        case .bothOutOfRange:
            return "Neither device can reach the router's WiFi zone. Go back to preparation and move them closer, then try again!"
        }
    }

    /// The step-kind prefix that actually plays before this failure interrupts the
    /// sequence, mirrored by the sidebar's situational card list.
    var reachablePhases: [SimulationStepKind] {
        switch self {
        case .deviceOutOfRange(let kind) where kind == .deviceA:
            return [.introduction, .checkSender]
        case .deviceOutOfRange:
            return [.introduction, .checkSender, .sendToRouter, .checkTarget]
        case .bothOutOfRange, .routerOff:
            return [.introduction, .checkSender]
        }
    }

    /// True when a trailing "Unable to Send" card follows the failure card, only
    /// the single-device cases have one reachable leg left to explain as failed.
    var hasTerminalCard: Bool {
        if case .deviceOutOfRange = self { return true }
        return false
    }
}
