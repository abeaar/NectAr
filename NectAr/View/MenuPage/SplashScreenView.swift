//
//  SplashScreenView.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 16/08/26.
//

import SwiftUI

struct SplashScreenView: View {
    let onFinished: () -> Void
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            Image("Honeycomb")
                .resizable()
                .ignoresSafeArea()
            
            Image("SplashScreen")
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
                .accessibilityLabel(Text("nectAR"))
        }
        .onAppear {
            Task {
                try? await Task.sleep(for: .seconds(1.5))

                await MainActor.run {
                    onFinished()
                }
            }
        }
    }
}


#Preview {
    SplashScreenView(
        onFinished: {}
    )
}
