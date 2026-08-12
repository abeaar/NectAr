//
//  testfont.swift
//  NectAr
//
//  Created by abr on 11/08/26.
//

import SwiftUI

struct testfont: View {

    var body: some View {
        VStack(spacing: 16) {
            Text("Fredoka Regular").font(.custom("Fredoka-Regular", size: 28))
            Text("Fredoka Medium").font(.custom("Fredoka-Medium", size: 28))
            Text("Fredoka SemiBold").font(.custom("Fredoka-SemiBold", size: 28))
            Text("Fredoka Bold").font(.custom("Fredoka-Bold", size: 28))
        }
    }
}
#Preview {
    testfont()
}
