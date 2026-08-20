//
//  DeviceKind.swift
//  NectAr
//
//  Created by abr on 03/08/26.
//

import Foundation
import ARKit

enum DeviceKind: CaseIterable, Hashable {
    case deviceA
    case router
    case deviceB

    var label: String {
        switch self {
        case .deviceA: return "Phone"
        case .router: return "Router"
        case .deviceB: return "Laptop"
        }
    }

    var icon: String {
        switch self {
        case .deviceA: return "Phone"
        case .router: return "Router"
        case .deviceB: return "Laptop"
        }
    }

    /// The raycast alignment this device requires for placement. Router can be
    /// wall-mounted (G3); clients stay on horizontal surfaces.
   
}
