//
//  SplashScreenView.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 16/08/26.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            //placeholder
            VStack(spacing: 10) {
                Image("nectar-logo-2")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 225)
                
                Text("hello world")
                    .font(Font.custom("Fredoka-Medium", size: 46, relativeTo: .title))
                    .foregroundStyle(Theme.brown)
            }
        }
    }
}


#Preview {
    SplashScreenView()
}
