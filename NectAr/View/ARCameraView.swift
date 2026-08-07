//
//  ARCameraView.swift
//  NectAr
//
//  Created by abr on 01/08/26.
//

import Foundation
import SwiftUI

struct ARCameraView: View {
    let arViewModel: ARViewModel<ARSessionManager>
    let placementController: PlacementSceneController
    let mascotController: MascotOnboardingController
    let onComplete: (PlacedTopology) -> Void
    @State private var isDebugModeOn = false

    var body: some View {
        ZStack(alignment: .top) {
            ARContainerView(arView: arViewModel.arView, isDebugModeOn: isDebugModeOn, controller: placementController, mascotController: mascotController)
                .ignoresSafeArea()

            if !placementController.isPreviewActive {
                CrosshairView()
            }
            HintTextView(hintText: mascotController.mascotHint ?? placementController.placementDistanceHint ?? arViewModel.hintText)
            DebugToggleButton(isDebugModeOn: $isDebugModeOn)
            PlacementActionButtonsView(placementController: placementController, mascotController: mascotController, onComplete: onComplete)
            BackButton {}
        }
        .safeAreaInset(edge: .leading) {
            DeviceSelectorView(controller: placementController, mascotController: mascotController)
        }
        .onAppear {
            arViewModel.start()
        }
    }
}
