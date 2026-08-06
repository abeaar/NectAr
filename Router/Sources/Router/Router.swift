import Foundation

/// The bundle containing this package's Reality Composer Pro content
/// (`Router.rkassets`: `Router.usdz`/`.usda`, `mail.usda`/`.usdz`).
///
/// Used by `DeviceEntityLoader` in the NectAr app target to load entities by name,
/// e.g. `Entity(named: "Router", in: routerBundle)`.
public let routerBundle = Bundle.module