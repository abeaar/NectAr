import RealityKit

/// Whether this entity currently shows the pulsing highlight used to draw
/// attention to it while a simulation sidebar step focused on it is selected.
struct HighlightComponent: Component {
    var isHighlighted: Bool = false
}
