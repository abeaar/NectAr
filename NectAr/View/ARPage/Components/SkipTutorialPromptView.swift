//
//  SkipTutorialPromptView.swift
//  NectAr
//

import SwiftUI

/// Placeholder yes/no prompt for the skip-tutorial step, flagged for a real
/// design pass, no matching asset exists in the catalog yet.
struct SkipTutorialPromptView: View {
    let onSkip: () -> Void
    let onContinue: () -> Void

    var body: some View {
        HStack(spacing: 32) {
            Button(action: onSkip) {
                VStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 44))
                    Text("Skip")
                        .font(.custom("Fredoka-Medium", size: 16, relativeTo: .caption))
                }
            }

            Button(action: onContinue) {
                VStack(spacing: 6) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 44))
                    Text("Continue")
                        .font(.custom("Fredoka-Medium", size: 16, relativeTo: .caption))
                }
            }
        }
        .foregroundStyle(Theme.brown)
        .padding(20)
        .background(Theme.cream)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    SkipTutorialPromptView(onSkip: {}, onContinue: {})
}
