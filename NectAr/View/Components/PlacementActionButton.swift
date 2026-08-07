//
//  PlacementActionButton.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 06/08/26.
//

import SwiftUI

struct PlacementActionButton: View {
    @State var isComplete: Bool = false
    @State var isUndo: Bool = false
    @State var isRedo: Bool = false
    
    var body: some View {
        HStack {
            VStack(spacing: 16) {
                Button(action: {
                    self.isRedo.toggle()
                }) {
                    Image(systemName: "arrow.uturn.forward.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Button(action: {
                    self.isUndo.toggle()
                }) {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.bottom, 20)
                
                Button(action: {
                    self.isComplete.toggle()
                }) {
                    Image(systemName: isComplete ? "play.circle.fill" : "plus.circle.fill")
                        .font(.system(size: 85))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
// for dev only
//        .background(.gray)
    }
}

#Preview {
    PlacementActionButton()
}
