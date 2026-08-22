import Foundation

/// One explained step of the deviceA-to-deviceB delivery shown in the simulation
/// sidebar, the representative direction the return leg mirrors from deviceB's side.
enum SimulationStepKind: CaseIterable, Identifiable {
    case introduction
    case checkSender
    case sendToRouter
    case checkTarget
    case sendToTarget
    case targetReceives

    var id: Self { self }

    var title: String {
        switch self {
        case .introduction: "Introduction"
        case .checkSender: "Form The Data Packet"
        case .sendToRouter: "Send To Router"
        case .checkTarget: "Router Reads The Address"
        case .sendToTarget: "Send To Target"
        case .targetReceives: "Target Receives"
        }
    }

    var explanation: String {
        switch self {
        case .introduction: "Let's learn how a text message travels from one device to another!"
        case .checkSender: "When you send a text, your message turns into a tiny piece of information called a Data Packet."
        case .sendToRouter: "The packet travels straight to your router."
        case .checkTarget: "The router is like a digital post office. It reads the packet's address to know exactly where it needs to go!"
        case .sendToTarget: "The router sends the packet to the other phone."
        case .targetReceives: "Once the other device gets the message, it sends a tiny packet back to you to say, 'I got the message!'"
        }
    }

    /// The placed entity this step's explanation, highlight, and any future
    /// editing UI concerns.
    var focusDeviceKind: DeviceKind {
        switch self {
        case .introduction: .deviceA
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

/// What the simulation is currently playing: the narrated first-loop round trip,
/// the second loop's continuously-looping full preview, a single sidebar step
/// looped in isolation, or a specific leg's wall-obstructed travel.
enum SimulationPlaybackSelection: Equatable {
    case full
    case fullPreview
    case step(SimulationStepKind)
    case wall(SimulationStepKind)
}

/// Identifies which sidebar card should be highlighted right now during the
/// auto-playing full sequence, set explicitly by the controller in lockstep with
/// the mail animation rather than inferred from separate state changes.
enum SimulationCardID: Equatable {
    case step(SimulationStepKind)
    case wall(SimulationStepKind)
    case failure
    case terminal
    case fullSimulation
}

/// Whether the simulation is still auto-narrating the first successful run, or has
/// switched to the second loop's tap-to-preview-each-card mode after the quiz
/// prompt was declined.
enum SimulationLoopMode: Equatable {
    case narrated
    case manual
}
