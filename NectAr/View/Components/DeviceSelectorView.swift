//
//  Untitled.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 07/08/26.
//

import SwiftUI

struct DeviceSelectorView: View {
    let controller: PlacementSceneController
    
    // mock
    var isPlaced: Bool = false
    
    var body: some View {
        VStack {
            ForEach(DeviceKind.allCases, id: \.self) { kind in

                Button {
                    controller.selectedDeviceKind = kind
                } label: {
                    VStack(spacing: 4) {
                        Image(kind.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                    }
                    .padding(10)
                }
                .disabled(isPlaced)
                .opacity(isPlaced ? 0.5 : 1.0)
            }
        }
    }
}

#Preview {
    DeviceSelectorView(controller: PlacementSceneController())
}
