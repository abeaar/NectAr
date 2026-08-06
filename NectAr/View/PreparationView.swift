//
//  PreparationView.swift
//  NectAr
//
//  Created by abr on 02/08/26.
//

import Foundation
import SwiftUI

struct PreparationView: View {
    @State private var selection: Story.ID?
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly

    let arViewModel: ARViewModel<ARSessionManager>
    let placementController: PlacementSceneController
    let onComplete: (PlacedTopology) -> Void

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            StoryView(selection: $selection)
        } detail: {
            ARCameraView(arViewModel: arViewModel, placementController: placementController, onComplete: onComplete)
        }
    }
}
