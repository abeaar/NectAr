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
    let onBack: () -> Void
    let onComplete: (PlacedTopology) -> Void
    @State private var isDebugModeOn = false

    var body: some View {
        ZStack(alignment: .top) {
            ARContainerView(arView: arViewModel.arView, controller: placementController, mascotController: mascotController)
                .ignoresSafeArea()

            if !placementController.isPreviewActive {
                CrosshairView()
            }
            HintTextView(hintText: mascotController.mascotHint ?? placementController.placementDistanceHint ?? arViewModel.hintText)
            DebugToggleButton(isDebugModeOn: $isDebugModeOn)
            BackButton {
                placementController.stopPreview()
                onBack()
            }
        }
        .overlay(alignment: .trailing) {
            PlacementActionButton(placementController: placementController, mascotController: mascotController, onComplete: onComplete)
                .padding(.trailing, 24)
        }
        .safeAreaInset(edge: .leading) {
            DeviceSelectorView(controller: placementController, mascotController: mascotController)
        }
        .onAppear {
            arViewModel.start()
        }
        .onChange(of: isDebugModeOn) { _, newValue in
            placementController.setRangeSphereVisible(newValue)
        }
    }
}
