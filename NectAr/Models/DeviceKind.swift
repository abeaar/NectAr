//
//  DeviceKind.swift
//  NectAr
//
//  Created by abr on 03/08/26.
//

import Foundation

enum DeviceKind: CaseIterable, Hashable {
    case deviceA
    case router
    case deviceB

    var label: String {
        switch self {
        case .deviceA: return "Device A"
        case .router: return "Router"
        case .deviceB: return "Device B"
        }
    }

    var icon: String {
        switch self {
        case .deviceA: return "iphone"
        case .router: return "wifi.router"
        case .deviceB: return "ipad"
        }
    }
}
