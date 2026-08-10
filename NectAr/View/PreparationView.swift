//
//  PreparationView.swift
//  NectAr
//
//  Created by abr on 02/08/26.
//

import Foundation
import SwiftUI

struct PreparationView: View {
    let arViewModel: ARViewModel<ARSessionManager>
    let placementController: PlacementSceneController
    let mascotController: MascotOnboardingController
    let onBack: () -> Void
    let onComplete: (PlacedTopology) -> Void

    var body: some View {
        ARCameraView(arViewModel: arViewModel, placementController: placementController, mascotController: mascotController, onBack: onBack, onComplete: onComplete)
    }
}
