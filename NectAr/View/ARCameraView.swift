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
    @State private var isDebugModeOn = false

    var body: some View {
        ZStack(alignment: .top) {
            // ARContainerView(session: arViewModel.arSession) for prod
            ARContainerView(session: arViewModel.arSession, isDebugModeOn: isDebugModeOn)
                .ignoresSafeArea()

            Text(arViewModel.hintText)
                .padding()
                .background(.black.opacity(0.6))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .padding(.top, 60)
        //for debug, delete later in prod
            HStack {
                Spacer()
                Button {
                    isDebugModeOn.toggle()
                } label: {
                    Image(systemName: isDebugModeOn ? "eye" : "eye.slash")
                        .padding()
                        .background(.black.opacity(0.6))
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                }
                .padding(.trailing, 20)
                .padding(.top, 60)
            }
        }
        .onAppear {
            arViewModel.start()
        }
    }
}
