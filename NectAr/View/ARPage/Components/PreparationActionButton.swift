//
//  PreparationActionButton.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 06/08/26.
//

import SwiftUI

struct PreparationActionButton: View {

    let placementViewModel: PlacementViewModel
    let mascotViewModel: MascotViewModel
    let onComplete: (PlacedTopology) -> Void

    var body: some View {
        HStack {
            VStack(spacing: 16) {
                Button(action: {
                    placementViewModel.undoLastPlacement()
                }) {
                    Image("UndoButton2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44)
                }
                .padding(.bottom, 16)
                .disabled(!placementViewModel.canUndo)
                .opacity(placementViewModel.canUndo ? 1.0 : 0.5)

                Button(action: {
                    tapAction()
                }) {
                    Image(actionAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64)
                }
            }
        }
    }

    private func tapAction() {
        guard !mascotViewModel.isActive else { return }

        if placementViewModel.isComplete {
            placementViewModel.finishPlacement()
            onComplete(PlacedTopology(transforms: placementViewModel.placedTransforms))
        } else {
            placementViewModel.confirmPlacement()
        }
    }

    private var actionAssetName: String {
        placementViewModel.isComplete ? "PlayButton2" : "PlusButton2"
    }
}

#Preview {
    PreparationActionButton(
        placementViewModel: PlacementViewModel(),
        mascotViewModel: MascotViewModel(),
        onComplete: { _ in }
    )
}
