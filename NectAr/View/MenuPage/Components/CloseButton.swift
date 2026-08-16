//
//  CloseButton.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 10/08/26.
//

import SwiftUI

struct CloseButton: View {
    let action: () -> Void
    
    var body: some View {
            Button(action: {
                action()
            }) {
                Image("CloseButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
            }
        }
}
