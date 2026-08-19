import Foundation

struct RouterAttributes: Equatable {
    var isOn: Bool = true
    var range: Float = 10.0

    var maxConnectedDevices: Int = 5
    var frequencyBand: FrequencyBand = .band5GHz
    var name: String?
    var password: String?
}
