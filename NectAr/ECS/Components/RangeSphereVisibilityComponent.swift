import RealityKit

/// Whether the placed router's range sphere currently renders, toggled by the
/// preparation-phase debug button, kept separate from `RouterAttributes`.
struct RangeSphereVisibilityComponent: Component {
    var isVisible: Bool
}
