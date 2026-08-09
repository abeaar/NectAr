//
//  PreparationView.swift
//  NectAr
//
//  Created by abr on 02/08/26.
//

import SwiftUI
import Foundation
import SwiftUI

struct PreparationView: View {
    @State private var selection: Story.ID?
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
    
    let arViewModel: ARViewModel<ARSessionManager>
    let placementController: PlacementSceneController
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            ARCameraView(arViewModel: arViewModel)
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

#Preview {
    PreparationView(arViewModel: ARViewModel(), placementController: PlacementSceneController(), onComplete: {})
}
