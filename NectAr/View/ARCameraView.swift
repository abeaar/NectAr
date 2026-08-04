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
    let onComplete: (PlacedTopology) -> Void
    @State private var isDebugModeOn = false

    var body: some View {
        ZStack(alignment: .top) {
            ARContainerView(arView: arViewModel.arView, isDebugModeOn: isDebugModeOn, controller: placementController)
                .ignoresSafeArea()

            CrosshairView()
            HintTextView(hintText: arViewModel.hintText)
            DebugToggleButton(isDebugModeOn: $isDebugModeOn)
            PlacementActionButtonsView(placementController: placementController, onComplete: onComplete)
        }
        .safeAreaInset(edge: .bottom) {
            DeviceSelectorView(controller: placementController)
        }
        .onAppear {
            arViewModel.start()
        }
    }
}
