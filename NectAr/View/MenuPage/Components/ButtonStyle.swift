//
//  ButtonStyle.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 19/08/26.
//

import SwiftUI

struct ButtonStyle: View {
    let action: () -> Void
    var backgroundColor: Color = Theme.cream2
    var textColor: Color = Theme.brown
    var text: String = "Button"
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text(text)
                .font(Font.custom("SourGummy-Bold", size: 32, relativeTo: .title2))
                .foregroundStyle(textColor)
                .frame(width: 135, height: 48)
                .background(backgroundColor)
                .cornerRadius(9)
        }
    }
}

#Preview {
    ButtonStyle {
        action: do {}
    }
}
