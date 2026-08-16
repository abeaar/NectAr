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
            
            Image("SplashScreen")
                .ignoresSafeArea()
                .scaledToFit()
        }
    }
}


#Preview {
    SplashScreenView()
}
