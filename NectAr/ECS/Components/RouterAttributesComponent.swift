import RealityKit

/// Wraps `RouterAttributes` so a placed router entity carries its own live state,
/// read by `RangeVisualizationSystem` and `SimulationSceneController`.
struct RouterAttributesComponent: Component {
    var attributes: RouterAttributes
}
