import RealityKit

/// Mirrors the bee's current phase onto its entity, covering both the onboarding
/// find-the-bee intro and its later simulation-time guiding behavior. During
/// onboarding, `MascotOnboardingController` is the source of truth since
/// `@Observable` only tracks its own stored property. Once onboarding is
/// `.complete`, `SimulationSceneController` drives `.guiding` directly on this
/// component instead, since the onboarding controller isn't present in that phase.
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
