//
//  OnBoardingView.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 17/08/26.
//

import SwiftUI

struct OnBoardingView: View {
    // for bee animation
    @State private var isUp = false
    @State private var textIndex = 0

    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            Image("Honeycomb")
                .resizable()
                .ignoresSafeArea()

            VStack {

                HStack(spacing: 20) {
                    Image("AbeeIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .padding(.top, 100)
                        .offset(y: isUp ? -20 : 20)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: true)
                            ) {
                                isUp.toggle()
                            }
                        }

                    ZStack {
                        Image("OnBoardingCard")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 630)
                            .padding(.bottom, 100)

                        Text(OnBoarding.onboardingTexts[textIndex])
                            .font(Font.custom("Fredoka-Medium", size: 38, relativeTo: .title))
                            .frame(width: 480, height: 240, alignment: .leading)
                            .foregroundStyle(Theme.brown)
                            .minimumScaleFactor(0.4)
                            .offset(x: 27, y: -55)
                            .id(textIndex)
                             .transition(.opacity)
                    }
                }
            }
            VStack {
                Spacer()

                HStack {
                    Spacer()

                    Text("Tap to continue")
                        .font(Font.custom("Fredoka-SemiBold", size: 34, relativeTo: .title2))
                        .foregroundStyle(Theme.brown)
                        .padding(.trailing, 70)
                        .padding(.bottom, 36)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                if textIndex < OnBoarding.onboardingTexts.count - 1 {
                    textIndex += 1
                } else {
                    onContinue()
                }
            }
        }
    }
}

#Preview {
    OnBoardingView(onContinue: {})
}
