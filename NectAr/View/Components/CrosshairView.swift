//
//  CrosshairView.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 06/08/26.
//

import SwiftUI

struct CrossHairView: View {
    var body: some View {
        ZStack {
            ZStack {
                Rectangle()
                    .frame(width: 25, height: 6)
                Rectangle()
                    .frame(width: 6, height: 25)
            }
            .foregroundColor(.black)
            
            ZStack {
                Rectangle()
                    .frame(width: 21, height: 2)
                Rectangle()
                    .frame(width: 2, height: 21)
            }
            .foregroundColor(.white)
        }
    }
}

#Preview {
    CrossHairView()
}
