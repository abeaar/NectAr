//
//  PreparationView.swift
//  NectAr
//
//  Created by abr on 01/08/26.
//

import Foundation
import SwiftUI

struct PreparationView: View {
    let arViewModel: ARViewModel<ARSessionManager>
    
    let placementViewModel: PlacementViewModel
    
    let mascotViewModel: MascotViewModel
    
    let onBack: () -> Void
    let onComplete: (PlacedTopology) -> Void

    @State private var isDebugModeOn = false

    private var hintText: String {
        mascotViewModel.hintText ?? placementViewModel.hintText ?? arViewModel.hintText
    }

    var body: some View {
        ZStack(alignment: .top) {
            ARContainerView(
                arViewModel: arViewModel,
                placementViewModel: placementViewModel,
                mascotViewModel: mascotViewModel
            )
            .ignoresSafeArea()

            if !placementViewModel.isPreviewActive {
                CrosshairView()
            }
            HintTextView(hintText: hintText)
            DebugToggleButton(isDebugModeOn: $isDebugModeOn)
            BackButton {
                placementViewModel.tearDown()
                mascotViewModel.tearDown()
                arViewModel.pause()
                onBack()
            }
        }
        .overlay(alignment: .trailing) {
            PreparationActionButton(
                placementViewModel: placementViewModel,
                mascotViewModel: mascotViewModel,
                onComplete: onComplete
            )
            .padding(.trailing)
        }
        .safeAreaInset(edge: .leading) {
            DeviceSelectorView(placementViewModel: placementViewModel, mascotViewModel: mascotViewModel)
        }
        .onAppear {
            arViewModel.start()
        }
        .onChange(of: isDebugModeOn) { _, newValue in
            placementViewModel.setRangeSphereVisible(newValue)
        }
        .onChange(of: mascotViewModel.isActive, initial: true) { _, isActive in
            placementViewModel.setPreviewSuspended(isActive)
        }
    }
}
