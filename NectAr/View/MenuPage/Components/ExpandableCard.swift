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
    let onQuiz: () -> Void

    @Binding var expandedStoryID: Story.ID?
    @StateObject private var sound = SoundViewModel()

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
                        VStack(alignment: .leading) {
                            Text(story.title)
                                .font(Font.custom("Fredoka-Bold", size: 64, relativeTo: .title))
                                .foregroundStyle(Theme.brown)
                                .frame(width: 385, height: 70, alignment: .leading)
                                .minimumScaleFactor(0.4)
                            
                            Text(story.description)
                                .font(Font.custom("Fredoka-Medium", size: 22, relativeTo: .title2))
                                .foregroundStyle(Theme.brown)
                                .padding(16)
                                .frame(width: 385, height: 175)
                                .background(Theme.cream2)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .minimumScaleFactor(0.4)
                        }
                        .padding(.bottom, 20)
                        .transition(.scale)
                    }
                    
                    HStack (spacing: 20) {
                        Spacer()
                        if isExpanded {
                            Button(action: {
                                print("Quiz button tapped") // test
                            }) {
                                Image("QuizLock")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 46)
                            }
                            .transition(.scale)
                            
                            Button(action: {
                                sound.play("bubble.mp3")
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
                .padding(.trailing, 40)
                .frame(width: isExpanded ? 930 : 460, height: isExpanded ? 520 : 515)
                .background(Theme.storyCardExpanded)
                .clipShape(RoundedRectangle(cornerRadius: 39))
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 0)
                
                VStack {
                    ZStack {
                        
                        Image(story.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: isExpanded ? 415 : 400)
                            .clipShape(.rect(cornerRadius: 15))
                    }
                    .cornerRadius(28)
                    .offset(x: isExpanded ? -215 : 0)
                    
                    if !isExpanded {
                        Text(story.title)
                            .font(Font.custom("Fredoka-SemiBold", size: 34, relativeTo: .title))
                            .padding(.top, 12)
                            .foregroundStyle(Theme.brown)
                            .minimumScaleFactor(0.4)
                            .transition(.opacity)
                    }
                }
            }
            .onTapGesture {
                guard isActive else { return }

                if !isExpanded {
                    sound.play("bubble.mp3")
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
                story: Story(id:"texting", title: "WiFi", icon: "StoryCard-2", description: "Ever wonder how a text message from a phone reaches a laptop without any wires? It’s all thanks to Wi-Fi!\n\nJump in to see the invisible data packages flying around your own room!"),
                isActive: true,
                onPlay: {},
                onQuiz: {},
                expandedStoryID: $mockExpandedID
            )
        }
    }
    return PreviewWrapper()
}
