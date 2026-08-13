import RealityKit

/// Lets any placed entity self-report which `DeviceKind` it is, so a controller can
/// look one up from the scene by kind instead of tracking entity references itself.
struct DeviceIdentityComponent: Component {
    var kind: DeviceKind
}
