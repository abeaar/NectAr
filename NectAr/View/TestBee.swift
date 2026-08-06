//
//  TestBee.swift
//  NectAr
//
//  Created by abr on 06/08/26.
//

import Foundation
import SwiftUI
import RealityKit
import Bee

struct TestBee: View {
    var body: some View {
        RealityView { content in
            guard let bee = try? await Entity(named: "Bee", in: beeBundle) else {
                print("Failed to load Bee entity")
                return
            }
            content.add(bee)
        }
        .realityViewCameraControls(.orbit)
    }
}

#Preview {
    TestBee()
}
