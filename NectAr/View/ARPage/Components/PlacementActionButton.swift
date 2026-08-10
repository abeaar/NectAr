//
//  PlacementActionButton.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 06/08/26.
//

import SwiftUI

struct PlacementActionButton: View {
    
    let placementController: PlacementSceneController
    let mascotController: MascotOnboardingController
    let onComplete: (PlacedTopology) -> Void
    
    var body: some View {
        HStack {
            VStack(spacing: 16) {
                // Decorative, exactly as on the UI branch: the placement logic has no
                // redo (see a5e2bc8, which replaced redo with undo). Kept so the stack
                // matches the design; wire it up if redo ever lands.
                Image("Redo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55)
                
                Button(action: {
                    placementController.undoLastPlacement()
                }) {
                    Image("Undo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 55)
                }
                .padding(.bottom, 16)
                .disabled(!placementController.canUndo)
                .opacity(placementController.canUndo ? 1.0 : 0.5)
                
                Button(action: {
                    if mascotController.isActive {
                        mascotController.attemptFind()
                    } else if placementController.isComplete {
                        placementController.stopPreview()
                        onComplete(PlacedTopology(transforms: placementController.placedTransforms))
                    } else {
                        placementController.confirmPlacement()
                    }
                }) {
                    Image(actionAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                }
            }
        }
    }
    
    /// Resolves to asset-catalog images rather than SF Symbols, so the artwork stays
    /// in sync with the UI branch. No separate icon for the mascot-hunt phase — the
    /// bee itself is already visible in the AR scene, so a plus here is enough.
    private var actionAssetName: String {
        placementController.isComplete ? "PlayButton" : "PlusButton"
    }
}

#Preview {
    PlacementActionButton(
        placementController: PlacementSceneController(),
        mascotController: MascotOnboardingController(),
        onComplete: { _ in }
    )
}
