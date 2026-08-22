import RealityKit

/// Mirrors the bee's current phase onto its entity, covering both the onboarding
/// find-the-bee intro and its later simulation-time guiding behavior.
struct MascotStateComponent: Component {
    enum Phase {
        case hunting
        case animating
        case complete
        /// The bee follows the mail packet while it travels, set once simulation
        /// starts moving it and left on for the rest of the simulation.
        case guiding
    }

    var phase: Phase
}
