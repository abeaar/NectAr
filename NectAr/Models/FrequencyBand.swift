import Foundation

/// Wifi frequency band a placed router can be configured to use, trading range for
/// speed.
enum FrequencyBand: Equatable {
    case band2_4GHz
    case band5GHz
    case band6GHz
}
