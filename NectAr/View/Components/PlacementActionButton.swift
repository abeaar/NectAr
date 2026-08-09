//
//  PlacementActionButton.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 06/08/26.
//

import SwiftUI

struct PlacementActionButton: View {
    
    @State private var ActionButtonType = PlacementSceneController()
    
    // mock
    @State var isUndo: Bool = false
    @State var isRedo: Bool = false
    
    var body: some View {
        HStack {
            VStack(spacing: 16) {
                Button(action: {
                    self.isRedo.toggle()
                }) {
                    Image("Redo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 55)
                }
                .disabled(ActionButtonType.isPlaying)
                .opacity(ActionButtonType.isPlaying ? 0.5 : 1.0)
                
                Button(action: {
                    self.isUndo.toggle()
                }) {
                    Image("Undo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 55)
                }
                .padding(.bottom, 16)
                .disabled(ActionButtonType.isPlaying)
                .opacity(ActionButtonType.isPlaying ? 0.5 : 1.0)
                
                Button(action: {
                    ActionButtonType.handleButtonTap()
                }) {
                    Image(ActionButtonType.buttonIconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                }
            }
        }
    }
}

#Preview {
    PlacementActionButton()
}
