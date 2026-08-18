//
//  ExplanationHighlight.swift
//  NectAr
//

import SwiftUI

/// Pulsing glow placeholder that calls out whichever preparation UI element the
/// current explanation step is pointing at, flagged for visual tuning in Xcode.
private struct ExplanationHighlight: ViewModifier {
    let isActive: Bool

    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .overlay {
                if isActive {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Theme.yellow, lineWidth: 4)
                        .scaleEffect(isPulsing ? 1.12 : 1.0)
                        .opacity(isPulsing ? 0.0 : 0.8)
                        .allowsHitTesting(false)
                        .onAppear {
                            isPulsing = false
                            withAnimation(.easeOut(duration: 1.1).repeatForever(autoreverses: false)) {
                                isPulsing = true
                            }
                        }
                }
            }
    }
}

extension View {
    func explanationHighlight(isActive: Bool) -> some View {
        modifier(ExplanationHighlight(isActive: isActive))
    }
}
