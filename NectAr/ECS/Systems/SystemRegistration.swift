import RealityKit

/// Registers every custom `System`, called once from `NectArApp.init()`. Kept as a
/// plain function with no RealityKit types in its signature, so the App file itself
/// doesn't need `import RealityKit` and its `Scene` doesn't collide with SwiftUI's.
enum SystemRegistration {
    static func registerAll() {
        RangeVisualizationSystem.registerSystem()
        HighlightSystem.registerSystem()
        MascotFollowSystem.registerSystem()
    }
}
