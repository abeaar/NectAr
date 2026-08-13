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
        ZStack {
            VStack (alignment: .trailing ,spacing: 14){
                
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
                    VStack(alignment: .leading, spacing: 14) {
                        Text(story.title)
                            .font(Font.custom("Fredoka-Bold", size: 62, relativeTo: .title))
                            .frame(width: 475, height: 100, alignment: .leading)
                            .minimumScaleFactor(0.4)
                        
                        Text(story.description)
                            .font(Font.custom("Fredoka-Medium", size: 32, relativeTo: .title2))
                            .padding(16)
                            .frame(width: 475, height: 210)
                            .background(Theme.cream)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .minimumScaleFactor(0.4)
                    }
                    .padding(.bottom, 10)
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
                                .frame(height: 65)
                        }
                        .transition(.scale)
                        
                        Button(action: {
                            print("Play button tapped") // test
                        }) {
                            Image("startButton")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 65)
                        }
                        .transition(.scale)
                    }
                }
                
            }
            .padding(40)
            .frame(width: isExpanded ? 1100 : 300, height: isExpanded ? 580 : 200)
            .background(Theme.storyCardExpanded)
            .clipShape(RoundedRectangle(cornerRadius: 39))
            
            ZStack {
                Image("StoryCard")
                    .resizable()
                
                Image(story.icon)
                    .resizable()
                    .padding(75)
            }
            .frame(width: 525, height: 525)
            .offset(x: isExpanded ? -260 : 0)
            .onTapGesture {
                guard isActive else { return }
                
                if !isExpanded {
                    withAnimation(easeOutBack) {
                        expandedStoryID = story.id
                    }
                }
            }
        }
    }
}


#Preview {
    struct PreviewWrapper: View {
        @State private var mockExpandedID: String? = nil
        
        var body: some View {
            ExpandableCard(
                story: Story(id:"texting", title: "Streaming Youtube", icon: "AbeeIcon", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut."),
                isActive: true,
                onPlay: {},
                expandedStoryID: $mockExpandedID
            )
        }
    }
    return PreviewWrapper()
}
