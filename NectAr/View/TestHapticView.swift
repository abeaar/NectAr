//
//  TestHapticView.swift
//  NectAr
//
//

import SwiftUI

struct TestHapticView: View {
    @State private var counter = 0

    var body: some View {
        VStack(spacing: 24) {
            Text("Haptic Test")
                .font(.title)

            Text("Taps: \(counter)")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("Supports haptics: \(HapticEngine.shared.supportsHaptics ? "yes" : "no")")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("Trigger Haptic") {
                counter += 1
                HapticEngine.shared.impact()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    TestHapticView()
}
