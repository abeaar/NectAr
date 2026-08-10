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
    let onComplete: (PlacedTopology) -> Void
    var body: some View {
        ZStack {
            ARCameraView(arViewModel: arViewModel, placementController: placementController, mascotController: mascotController, onComplete: onComplete)
                .ignoresSafeArea()
            
            CrossHairView()
        }
        .overlay(alignment: .topLeading) {
            BackButton()
                .padding(.top, 16)
                .padding(.leading, 24)
        }
        .overlay(alignment: .leading) {
            DeviceSelectorView(controller: placementController)
                .padding(.leading, 24)
        }
        .overlay(alignment: .trailing) {
            PlacementActionButton()
                .padding(.trailing, 24) 
        }
    }
}

