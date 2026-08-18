import Foundation

/// One explained step of the deviceA-to-deviceB delivery shown in the simulation
/// sidebar, the representative direction the return leg mirrors from deviceB's side.
enum SimulationStepKind: CaseIterable, Identifiable {
    case checkSender
    case sendToRouter
    case checkTarget
    case sendToTarget
    case targetReceives

    var id: Self { self }

    var title: String {
        switch self {
        case .checkSender: "Form The Data Packet"
        case .sendToRouter: "Send To Router"
        case .checkTarget: "Router Reads The Address"
        case .sendToTarget: "Send To Target"
        case .targetReceives: "Target Receives"
        }
    }

    var explanation: String {
        switch self {
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

/// Text shown on the sidebar's top "Full Simulation" card, the playback mode
/// that loops the entire round trip instead of a single step.
struct SimulationFullCard {
    let title: String
    let explanation: String

    static let `default` = SimulationFullCard(
        title: "Full Simulation",
        explanation: "Let's learn how a text message travels from one device to another!"
    )
}
