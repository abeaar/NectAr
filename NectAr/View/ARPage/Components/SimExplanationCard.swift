//
//  ExplanationCard.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 13/08/26.
//

import SwiftUI

struct ExplanationCard: View {

    var title: String
    var description: String
    
    var body: some View {
        ZStack {
            Image("ExplanationCard")
            
            VStack(alignment: .leading, spacing: 6){
                Text(title)
                    .font(Font.custom("Fredoka-Bold", size: 28, relativeTo: .title2))
                    .foregroundStyle(Theme.brown)
                    .minimumScaleFactor(0.3)
                
                Text(description)
                    .font(Font.custom("Fredoka-Medium", size: 24, relativeTo: .body))
                    .foregroundStyle(Theme.brown)
                    .minimumScaleFactor(0.3)
            }
            .frame(width:285, height: 150)
//            .background(Color.black.opacity(0.3))
        }
    }
}

#Preview {
    ExplanationCard(title: "Lorem Ipsum", description: "Lorem ipsum dolor sit amet, elit, sed do eiusmod tempor incididunt ut. Woakwoakw awokawok")
}
