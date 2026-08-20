//
//  MenuView.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 10/08/26.
//

import SwiftUI

struct MenuView: View {
    let onStart: (Story.ID) -> Void
    let onQuiz: () -> Void

    @State private var activeStoryID: Story.ID?
    @State private var expandedStoryID: Story.ID?
    @StateObject private var sound = SoundViewModel()

    let cardWidth: CGFloat = 500

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            Image("Honeycomb")
                .resizable()
                .ignoresSafeArea()

            Image("MenuPageBG")
                .resizable()
                .ignoresSafeArea()

            GeometryReader { geometry in
                let horizontalPadding = (geometry.size.width - cardWidth) / 2

                ZStack {

                    VStack (spacing: 110) {
                        // carousel
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: -50) {
                                ForEach(StoryCatalog.all) { story in

                                    ExpandableCard(
                                        story: story,
                                        isActive: activeStoryID == story.id,
                                        onPlay: { onStart(story.id) },
                                        onQuiz: onQuiz,
                                        expandedStoryID: $expandedStoryID
                                    )
                                    .frame(width: cardWidth)
                                    .scrollTransition(axis: .horizontal) { content, phase in
                                        content
                                            .scaleEffect(phase.isIdentity ? 1.0 : 0.5)

                                    }
                                    .zIndex(expandedStoryID == story.id ? 2 : (activeStoryID == story.id ? 1 : 0))
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetLayout()
                    }
                    .frame(height: 500)
                    .scrollClipDisabled()
                    .safeAreaPadding(.horizontal, horizontalPadding)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $activeStoryID)
                    .onChange(of: activeStoryID) { oldValue, newValue in
                        guard oldValue != newValue else { return }
                        sound.play("CardBubble.mp3")
                        withAnimation(.easeInOut(duration: 0.3)) {
                            expandedStoryID = nil
                        }
                        .padding(.top, 100)

                        // pagination dots
                        HStack(spacing: 12) {
                            ForEach(StoryCatalog.all) { story in
                                Circle()
                                    .fill(activeStoryID == story.id ? Theme.brown : Theme.brown.opacity(0.3))
                                    .frame(width: 12, height: 12)
                                    .animation(.easeInOut, value: activeStoryID)
                            }
                        }
                        .onAppear {
                            if activeStoryID == nil {
                                activeStoryID = StoryCatalog.all.first?.id
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}

#Preview {
    MenuView(onStart: { _ in }, onQuiz: {})
}
