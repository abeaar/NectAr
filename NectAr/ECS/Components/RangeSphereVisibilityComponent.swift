import RealityKit

/// Whether the placed router's range sphere currently renders, toggled by the
/// preparation-phase debug button and kept separate from `RouterAttributes` since
/// it's a debug display concern, not a domain attribute.
struct RangeSphereVisibilityComponent: Component {
    var isVisible: Bool
}
