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

    let prepExplainVM: PrepExplainViewModel

    let onBack: () -> Void
    let onComplete: (PlacedTopology) -> Void

    @State private var isDebugModeOn = false

    private var isDeviceSelectorTheSpotlightTarget: Bool {
        prepExplainVM.currentHighlightTarget == .deviceSelector
    }

    private var isActionButtonTheSpotlightTarget: Bool {
        prepExplainVM.currentHighlightTarget == .actionButton
    }

    /// True while a narration beat that isn't tied to the mascot's own phase
    /// (an intro beat, a fully locked beat, or the spotlight overlay step)
    /// should hold off the ghost preview the same way the bee hunt already
    /// does. Excludes the device-placement steps, where the preview is
    /// exactly the point.
    private var isTutorialBlocking: Bool {
        mascotViewModel.isActive || prepExplainVM.hidesPlacementUI
            || prepExplainVM.locksPlacementUI || prepExplainVM.usesSpotlightOverlay
    }

    private var isDeviceSelectorDisabled: Bool {
        mascotViewModel.isActive || prepExplainVM.locksPlacementUI
            || (prepExplainVM.usesSpotlightOverlay && !isDeviceSelectorTheSpotlightTarget)
    }

    private var isActionButtonDisabled: Bool {
        mascotViewModel.isActive || prepExplainVM.locksPlacementUI
            || (prepExplainVM.usesSpotlightOverlay && !isActionButtonTheSpotlightTarget)
    }

    private var isDeviceSelectorDimmed: Bool {
        prepExplainVM.usesSpotlightOverlay && !isDeviceSelectorTheSpotlightTarget
    }

    private var isActionButtonDimmed: Bool {
        prepExplainVM.usesSpotlightOverlay && !isActionButtonTheSpotlightTarget
    }

    var body: some View {
        ZStack(alignment: .top) {
            if prepExplainVM.usesSpotlightOverlay {
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            if prepExplainVM.canAdvanceNow {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        prepExplainVM.advanceNow()
                    }
            }

            if !placementViewModel.isPreviewActive {
//                CrosshairView()
            }

            explanationCardView

            BackButton {
                placementViewModel.tearDown()
                mascotViewModel.tearDown()
                prepExplainVM.reset()
                arViewModel.pause()
                onBack()
            }

            if !prepExplainVM.hidesPlacementUI {
                PreparationActionButton(
                    placementViewModel: placementViewModel,
                    mascotViewModel: mascotViewModel,
                    isActionHighlighted: isActionButtonTheSpotlightTarget,
                    onComplete: onComplete
                )
                .disabled(isActionButtonDisabled)
                .opacity(isActionButtonDimmed ? 0.4 : 1.0)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .padding(.trailing)

                DeviceSelectorView(
                    placementViewModel: placementViewModel,
                    mascotViewModel: mascotViewModel,
                    isListHighlighted: isDeviceSelectorTheSpotlightTarget
                )
                .disabled(isDeviceSelectorDisabled)
                .opacity(isDeviceSelectorDimmed ? 0.4 : 1.0)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            arViewModel.start()
            mascotViewModel.attachPrepExplainService(prepExplainVM.service)
            placementViewModel.attachPrepExplainService(prepExplainVM.service)
        }
        .onChange(of: isDebugModeOn) { _, newValue in
            placementViewModel.setRangeSphereVisible(newValue)
        }
        .onChange(of: isTutorialBlocking, initial: true) { _, isBlocking in
            placementViewModel.setPreviewSuspended(isBlocking)
        }
        .onChange(of: prepExplainVM.currentStepID) { _, _ in
            prepExplainVM.refreshFinalStep(isComplete: placementViewModel.isComplete)
        }
    }

    /// Three ranks, narration always wins over the other two: narration (rank
    /// 1) picks between `ExplanationCard` and `HintTextView`/`PrepExplainCard`
    /// per step, the distance-gate hint (rank 2) and the tracking-status
    /// fallback (rank 3) only show during the silent stretch after step 6,
    /// see `PrepExplainService.isInFreeWindow`. Renders nothing at all
    /// otherwise, e.g. the brief gap while the bee flies through the camera.
    @ViewBuilder
    private var explanationCardView: some View {
        if let text = prepExplainVM.currentText {
            if prepExplainVM.currentCardStyle == .prepOnboardCard {
                PrepOnboardExplanationCard(description: text)
            } else {
                HintTextView(hintText: text)
            }
        } else if prepExplainVM.isInFreeWindow, let distanceHint = placementViewModel.hintText {
            HintTextView(hintText: distanceHint)
                .contentShape(Rectangle())
                .onTapGesture {
                    placementViewModel.advanceDistanceHintNow()
                }
        } else if prepExplainVM.isInFreeWindow, let trackingHint = arViewModel.hintText {
            HintTextView(hintText: trackingHint)
                .contentShape(Rectangle())
                .onTapGesture {
                    arViewModel.advanceHintNow()
                }
        }
    }
}

#Preview {
    PreparationView(
        arViewModel: ARViewModel(sessionManager: ARSessionManager()),
        placementViewModel: PlacementViewModel(),
        mascotViewModel: MascotViewModel(),
        prepExplainVM: PrepExplainViewModel(service: PrepExplainService()),
        onBack: {},
        onComplete: { _ in }
    )
}
