//
//  DeviceKind.swift
//  NectAr
//
//  Created by abr on 03/08/26.
//

import Foundation

/// The three fixed nodes of the topology this app visualizes. The set is intentionally
/// closed — see the PRD's non-goals (no more than three nodes, no arbitrary
/// topologies).
enum DeviceKind: CaseIterable, Hashable {
    case deviceA
    case router
    case deviceB

    /// Display name used in placement UI (`DeviceSelectorView`). The AR floating
    /// label shown above the placed entity differs for `.router` — see
    /// `DeviceEntityLoader.labelText(for:)`, which calls it "WiFi Box" instead.
    var label: String {
        switch self {
        case .deviceA: return "Device A"
        case .router: return "Router"
        case .deviceB: return "Device B"
        }
    }

    /// Asset-catalog name of the device selector card, not an SF Symbol — the artwork
    /// carries the icon and the label together, so `DeviceSelectorView` draws it with
    /// `Image(_:)` rather than `Image(systemName:)`.
    var icon: String {
        switch self {
        case .deviceA: return "DeviceA"
        case .router: return "Router"
        case .deviceB: return "DeviceB"
        }
    }
}
