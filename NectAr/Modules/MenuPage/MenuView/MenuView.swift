//
//  MenuView.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 10/08/26.
//

import SwiftUI

struct MenuView: View {
    
    @State private var presenter = MenuPresenter()

    private let cardWidth: CGFloat = 500

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
                                        story: story
                                    )
                                    .frame(width: cardWidth)
                                    .scrollTransition(axis: .horizontal) { content, phase in
                                        content
                                            .scaleEffect(phase.isIdentity ? 1.0 : 0.5)
                                    }
                                    .zIndex(presenter.expandedStoryID == story.id ? 2 : (presenter.activeStoryID == story.id ? 1 : 0))
                                }
                            }
                            .frame(height: 500)
                            .scrollClipDisabled()
                            .safeAreaPadding(.horizontal, horizontalPadding)
                            .scrollTargetBehavior(.viewAligned)
                            .scrollPosition(id: $presenter.activeStoryID)
                            .onChange(of: presenter.activeStoryID) { oldValue, newValue in
                                guard oldValue != newValue else { return }
                                //                            sound.play("CardBubble.mp3")
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    presenter.expandedStoryID = nil
                                }
                            }
                        }
                        .padding(.top, 85)
                        
                        HStack(spacing: 12) {
                            ForEach(StoryCatalog.all) { story in
                                Circle()
                                    .fill(presenter.activeStoryID == story.id ? Theme.brown : Theme.brown.opacity(0.3))
                                    .frame(width: 12, height: 12)
                                    .animation(.easeInOut, value: presenter.activeStoryID)
                            }
                        }
                        .onAppear {
                            if presenter.activeStoryID == nil {
                                presenter.activeStoryID = StoryCatalog.all.first?.id
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
    MenuView()
}
