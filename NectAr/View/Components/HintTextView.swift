//
//  HintTextView.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 07/08/26.
//

import SwiftUI

struct HintTextView: View {
    let hintText: String

    var body: some View {
        Text(hintText)
            .padding()
            .background(.black.opacity(0.6))
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}

#Preview {
    HintTextView(hintText: "Move your device to find a surface")
}
