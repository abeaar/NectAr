//
//  ARCameraView.swift
//  NectAr
//
//  Created by abr on 01/08/26.
//

import Foundation
import SwiftUI

struct ARCameraView: View {
    let arViewModel: ARViewModel<ARSessionManager>

    var body: some View {
        ZStack(alignment: .top) {
            ARContainerView(session: arViewModel.arSession)
                .ignoresSafeArea()

            Text(arViewModel.hintText)
                .padding()
                .background(.black.opacity(0.6))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .padding(.top, 60)
        }
        .onAppear {
            arViewModel.start()
        }
    }
}
