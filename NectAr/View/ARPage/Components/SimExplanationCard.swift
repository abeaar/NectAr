//
//  ExplanationCard.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 13/08/26.
//

import SwiftUI

struct SimExplanationCard: View {

    var title: String
    var description: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("ExplanationCard")
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(Font.custom("Fredoka-Bold", size: 22, relativeTo: .title2))
                    .foregroundStyle(Theme.brown)
                    .minimumScaleFactor(0.3)
                    .multilineTextAlignment(.leading)
                Text(description)
                    .font(Font.custom("Fredoka-Medium", size: 22, relativeTo: .title2))
                    .foregroundStyle(Theme.brown)
                    .minimumScaleFactor(0.3)
                    .multilineTextAlignment(.leading)
            }
            .frame(width: 285, height: 150, alignment: .topLeading)   
            .padding(.top, 30)
            .padding(.leading, 30)
        }
    }
}

#Preview {
    SimExplanationCard(title: "Lorem Ipsum", description: "cape jir CAPE JIR")
}
