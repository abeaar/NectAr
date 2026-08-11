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
    }
}
