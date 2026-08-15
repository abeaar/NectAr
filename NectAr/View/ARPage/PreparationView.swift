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
//                CrosshairView()
            }

            HintTextView(hintText: hintText)
                .padding(.leading, 80)

            BackButton {
                placementViewModel.tearDown()
                mascotViewModel.tearDown()
                arViewModel.pause()
                onBack()
            }

            PreparationActionButton(
                placementViewModel: placementViewModel,
                mascotViewModel: mascotViewModel,
                onComplete: onComplete
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            .padding(.trailing)

            DeviceSelectorView(placementViewModel: placementViewModel, mascotViewModel: mascotViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .onAppear {
            arViewModel.start()
        }
    }
}

#Preview {
    PreparationView(
        arViewModel: ARViewModel(sessionManager: ARSessionManager()),
        placementViewModel: PlacementViewModel(),
        mascotViewModel: MascotViewModel(),
        onBack: {},
        onComplete: { _ in }
    )
}
