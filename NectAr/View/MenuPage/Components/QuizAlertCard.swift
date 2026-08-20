//
//  QuizAlertCard.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 19/08/26.
//

import SwiftUI

struct QuizAlertCard: View {
    let onExitToMenu: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            
            Image("AlertCard")
            
            VStack(spacing: 12) {
                Text("Alert!")
                    .font(Font.custom("SourGummy-Bold", size: 34, relativeTo: .largeTitle))
                    .frame(width: 345)
                
                Text("Are you sure want to leave the quiz and go back to the menu?")
                    .font(Font.custom("Fredoka-Medium", size: 24, relativeTo: .title2))
                    .frame(width: 345)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 22) {
                    ButtonStyle(
                        action: onCancel,
                        backgroundColor: Theme.red,
                        textColor: Theme.cream2,
                        text: "No"
                    )
                    
                    ButtonStyle(
                        action: onExitToMenu,
                        backgroundColor: Theme.yellow,
                        textColor: Theme.brown,
                        text: "Yes"
                    )
                }
                .padding(.top, 18)
            }
        }
    }
}

#Preview {
    QuizAlertCard(onExitToMenu: {}, onCancel: {})
}
