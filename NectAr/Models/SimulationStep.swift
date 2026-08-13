import Foundation

/// One explained step of the deviceA-to-deviceB delivery shown in the simulation
/// sidebar. The full round trip's return leg (deviceB back to deviceA) plays the
/// same shape from deviceB's perspective, this list only names the representative
/// direction the sidebar's cards explain.
enum SimulationStepKind: CaseIterable, Identifiable {
    case checkSender
    case sendToRouter
    case checkTarget
    case sendToTarget
    case targetReceives

    var id: Self { self }

    var title: String {
        switch self {
        case .checkSender: "Check Sender's Signal"
        case .sendToRouter: "Send To Router"
        case .checkTarget: "Check Target's Signal"
        case .sendToTarget: "Send To Target"
        case .targetReceives: "Target Receives"
        }
    }

    var explanation: String {
        switch self {
        case .checkSender: "Device A checks whether it's inside the router's WiFi zone before sending."
        case .sendToRouter: "The message travels from Device A to the router."
        case .checkTarget: "The router checks whether Device B is inside its WiFi zone."
        case .sendToTarget: "The router forwards the message on to Device B."
        case .targetReceives: "Device B receives the message."
        }
    }

    /// The placed entity this step's explanation, highlight, and any future
    /// editing UI concerns.
    var focusDeviceKind: DeviceKind {
        switch self {
        case .checkSender: .deviceA
        case .sendToRouter, .sendToTarget: .router
        case .checkTarget, .targetReceives: .deviceB
        }
    }

    /// True for the two steps that move the mail packet, false for the range
    /// checks and the terminal arrival, which show a highlight instead.
    var involvesMovement: Bool {
        self == .sendToRouter || self == .sendToTarget
    }
}

/// What the simulation is currently playing: the full looping round trip, or a
/// single sidebar step looped in isolation for explanation.
enum SimulationPlaybackSelection: Equatable {
    case full
    case step(SimulationStepKind)
}
