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
            
            VStack(alignment: .leading, spacing: 10){
                Text(title)
                    .font(Font.custom("Fredoka-Bold", size: 34, relativeTo: .title2))
                    .foregroundStyle(Theme.brown)
                    .minimumScaleFactor(0.4)
                
                Text(description)
                    .font(Font.custom("Fredoka-Medium", size: 26, relativeTo: .body))
                    .foregroundStyle(Theme.brown)
                    .minimumScaleFactor(0.4)
            }
            .frame(width: 390, height: 160)
                
        }
    }
}

#Preview {
    ExplanationCard(title: "Lorem Ipsum", description: "Lorem ipsum dolor sit amet, elit, sed do eiusmod tempor incididunt ut. Woakwoakw awokawok")
}
