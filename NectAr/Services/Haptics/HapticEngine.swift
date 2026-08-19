//
//  HapticEngine.swift
//  NectAr
//
//

import UIKit
import CoreHaptics

final class HapticEngine {
    static let shared = HapticEngine()

    var supportsHaptics: Bool = false
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)

    init() {
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        supportsHaptics = hapticCapability.supportsHaptics
    }

    func impact() {
        guard supportsHaptics else { return }
        heavy.impactOccurred()
    }
}
