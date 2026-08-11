//
//  PreparationView.swift
//  NectAr
//
//  Created by abr on 01/08/26.
//

import Foundation
import SwiftUI

struct PreparationView: View {
    let viewModel: PreparationViewModel
    let onBack: () -> Void
    let onComplete: (PlacedTopology) -> Void

    var body: some View {
        ZStack(alignment: .top) {
            ARContainerView(viewModel: viewModel)
                .ignoresSafeArea()

            if !viewModel.isPreviewActive {
                CrosshairView()
            }
            HintTextView(hintText: viewModel.hintText)
            BackButton {
                viewModel.exitToMenu(then: onBack)
            }
        }
        .overlay(alignment: .trailing) {
            PreparationActionButton(viewModel: viewModel, onComplete: onComplete)
                .padding(.trailing, 24)
        }
        .safeAreaInset(edge: .leading) {
            DeviceSelectorView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.start()
        }
    }
}
