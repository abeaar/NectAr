import RealityKit

/// Wraps `DeviceAttributes` so a placed device marker entity carries its own message
/// directly, rather than the app tracking it separately from the entity.
struct DeviceAttributesComponent: Component {
    var attributes: DeviceAttributes
}
