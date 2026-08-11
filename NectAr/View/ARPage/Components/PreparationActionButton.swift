//
//  PreparationActionButton.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 06/08/26.
//

import SwiftUI

struct PreparationActionButton: View {

    let viewModel: PreparationViewModel
    let onComplete: (PlacedTopology) -> Void

    var body: some View {
        HStack {
            VStack(spacing: 16) {
        
                Image("Redo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55)

                Button(action: {
                    viewModel.undoLastPlacement()
                }) {
                    Image("Undo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 55)
                }
                .padding(.bottom, 16)
                .disabled(!viewModel.canUndo)
                .opacity(viewModel.canUndo ? 1.0 : 0.5)

                Button(action: {
                    viewModel.tapActionButton(onComplete: onComplete)
                }) {
                    Image(actionAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                }
            }
        }
    }

    private var actionAssetName: String {
        viewModel.isComplete ? "PlayButton" : "PlusButton"
    }
}

#Preview {
    PreparationActionButton(
        viewModel: PreparationViewModel(
            arViewModel: ARViewModel(),
            placementController: PreparationSceneController(),
            mascotController: MascotOnboardingController()
        ),
        onComplete: { _ in }
    )
}
