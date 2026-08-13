import RealityKit

/// Wraps `RouterAttributes` so a placed router entity carries its own live state,
/// read by `RangeVisualizationSystem` and `SimulationSceneController` instead of the
/// app re-deriving fresh defaults each time.
struct RouterAttributesComponent: Component {
    var attributes: RouterAttributes
}
