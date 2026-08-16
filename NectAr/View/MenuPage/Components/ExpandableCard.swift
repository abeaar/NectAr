//
//  ExpandableCard.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 09/08/26.
//

import SwiftUI

struct ExpandableCard: View {
    let story: Story
    let isActive: Bool
    let onPlay: () -> Void

    @Binding var expandedStoryID: Story.ID?
    
    var isExpanded: Bool {
        expandedStoryID == story.id
    }
    
    // animation
    let easeOutBack = Animation.timingCurve(0.175, 0.885, 0.32, 1.275, duration: 0.5)
    let easeInBack = Animation.timingCurve(0.6, -0.28, 0.735, 0.045, duration: 0.5)
    
    var body: some View {
        VStack(spacing: 26) {
            ZStack {
                VStack (alignment: .trailing ,spacing: 8){
                    HStack {
                        if isExpanded {
                            CloseButton(action: {
                                withAnimation(easeInBack) {
                                    expandedStoryID = nil
                                }
                            })
                            .transition(.scale)
                        }
                    }
                    
                    if isExpanded {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(story.title)
                                .font(Font.custom("Fredoka-Bold", size: 48, relativeTo: .title))
                                .foregroundStyle(Theme.brown)
                                .frame(width: 385, height: 100, alignment: .leading)
                                .minimumScaleFactor(0.4)
                            
                            Text(story.description)
                                .font(Font.custom("Fredoka-Medium", size: 24, relativeTo: .title2))
                                .foregroundStyle(Theme.brown)
                                .padding(16)
                                .frame(width: 385, height: 175)
                                .background(Theme.cream)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .minimumScaleFactor(0.4)
                        }
                        .padding(.bottom, 12)
                        .transition(.scale)
                    }
                    
                    HStack (spacing: 26) {
                        Spacer()
                        if isExpanded {
                            Button(action: {
                                print("Quiz button tapped") // test
                            }) {
                                Image("quizButton")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 46)
                            }
                            .transition(.scale)
                            
                            Button(action: {
                                onPlay()
                            }) {
                                Image("startButton")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 46)
                            }
                            .transition(.scale)
                        }
                    }
                    
                }
                .padding(.trailing, 38)
                .frame(width: isExpanded ? 930 : 420, height: isExpanded ? 520 : 420)
                .background(Theme.storyCardExpanded)
                .clipShape(RoundedRectangle(cornerRadius: 39))
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 0)
                
                VStack {
                    ZStack {
                        
                        Image(story.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: isExpanded ? 415 : 350)
                            .clipShape(.rect(cornerRadius: 15))
                    }
                    .cornerRadius(30)
                    .offset(x: isExpanded ? -210 : 0)
                }
            }
            .onTapGesture {
                guard isActive else { return }
                
                if !isExpanded {
                    withAnimation(easeOutBack) {
                        expandedStoryID = story.id
                    }
                }
            }
            if !isExpanded {
                Text(story.title)
                    .font(Font.custom("Fredoka-bold", size: 38, relativeTo: .title))
                    .foregroundStyle(Theme.brown)
                    .minimumScaleFactor(0.4)
                    .transition(.opacity)
            }
        }
    }
}


#Preview {
    struct PreviewWrapper: View {
        @State private var mockExpandedID: String? = nil
        
        var body: some View {
            ExpandableCard(
                story: Story(id:"texting", title: "Streaming Youtube", icon: "StoryCard-2", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut."),
                isActive: true,
                onPlay: {},
                expandedStoryID: $mockExpandedID
            )
        }
    }
    return PreviewWrapper()
}
