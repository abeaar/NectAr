import RealityKit

/// Registers every custom `Component` and `System`, called once from `NectArApp.init()`.
/// A plain function so `NectArApp.swift` avoids RealityKit's `Scene` colliding with SwiftUI's.
enum SystemRegistration {
    static func registerAll() {
        DeviceAttributesComponent.registerComponent()
        DeviceIdentityComponent.registerComponent()
        HighlightComponent.registerComponent()
        MascotStateComponent.registerComponent()
        RangeSphereVisibilityComponent.registerComponent()
        RouteComponent.registerComponent()
        RouterAttributesComponent.registerComponent()

        RangeVisualizationSystem.registerSystem()
        HighlightSystem.registerSystem()
        MascotFollowSystem.registerSystem()
    }
}
