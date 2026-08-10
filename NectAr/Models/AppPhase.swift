//
//  AppPhase.swift
//  NectAr
//
//  Created by abr on 01/08/26.
//

import Foundation

/// The app's only navigation state.
///
/// There is no navigation stack — this enum *is* the router. `ContentView` switches on
/// it directly, and `.simulation` carries the payload (``PlacedTopology``) captured
/// during `.preparation` forward into the simulation screen.
enum AppPhase {
    /// The user is choosing a scenario story to walk through.
    case menu
    /// The user is placing Device A, Router, and Device B markers in AR.
    case preparation
    /// The user is watching the mail packet animate through the placed topology.
    case simulation(PlacedTopology)
}
