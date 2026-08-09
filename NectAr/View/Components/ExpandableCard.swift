//
//  ExpandableCard.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 09/08/26.
//

import SwiftUI

struct ExpandableCard: View {
    @State private var isExpanded: Bool = false
    
    // animation
    let easeOutBack = Animation.timingCurve(0.175, 0.885, 0.32, 1.275, duration: 0.5)
    let easeInBack = Animation.timingCurve(0.6, -0.28, 0.735, 0.045, duration: 0.5)
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    if isExpanded {
                        Button(action: {
                            withAnimation(easeInBack) {
                                isExpanded = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.gray)
                        }
                        .transition(.opacity)
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    if isExpanded {
                        Button(action: {
                            print("Play button tapped") // test
                        }) {
                            Text("Play")
                                .font(.title3.bold())
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        .transition(.opacity)
                    }
                }
            }
            .padding(24)
            
            .frame(width: isExpanded ? 1100 : 300, height: isExpanded ? 750 : 200)
            .background(Color(white: 0.9))
            .clipShape(RoundedRectangle(cornerRadius: 32))
            
            ZStack {
                Color.gray
                
                if !isExpanded {
                    Text("Tap to expand")
                        .foregroundColor(.white.opacity(0.8))
                        .fontWeight(.medium)
                }
            }
            .frame(width: 500, height: 500)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .offset(x: isExpanded ? -220 : 0)
            .onTapGesture {
                if !isExpanded {
                    withAnimation(easeOutBack) {
                        isExpanded = true
                    }
                }
            }
        }
    }
}


#Preview {
    ExpandableCard()
}
