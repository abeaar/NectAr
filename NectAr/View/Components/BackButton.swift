//
//  BackButton.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 07/08/26.
//

import SwiftUI

struct BackButton: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left.circle.fill")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .background(.gray)
                .padding(10)
        }
    }
}
#Preview {
    BackButton()
}
