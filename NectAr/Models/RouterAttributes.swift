import Foundation

/// Configurable attributes for a placed `.router` device. `range` in meters is the
/// connectable radius used by `RouterRangeChecker`.
struct RouterAttributes: Equatable {
    var isOn: Bool = true
    var range: Float = 2.0
    var maxConnectedDevices: Int = 5
    var frequencyBand: FrequencyBand = .band5GHz
    var name: String?
    var password: String?
}
