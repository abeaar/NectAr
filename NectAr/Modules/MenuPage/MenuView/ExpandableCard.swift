//
//  ExpandableCard.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 09/08/26.
//

import SwiftUI

struct ExpandableCard: View {
    
//    @StateObject private var sound = SoundViewModel()

    @State private var presenter = MenuPresenter()
    
    let story: Story
    
    var body: some View {
        VStack(spacing: 26) {
            ZStack {
                VStack (alignment: .trailing ,spacing: 8){
                    HStack {
                        if presenter.isExpanded {
                            CloseButton(action: {
                                withAnimation(Theme.easeInBack) {
                                    presenter.expandedStoryID = nil
                                }
                            })
                            .transition(.scale)
                        }
                    }
                    
                    if presenter.isExpanded {
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
                        if presenter.isExpanded {
                            if story.id == "wifi" {
                                if presenter.isQuizUnlocked(for: story.id) {
                                    ButtonStyle(
                                        action: presenter.openQuiz,
                                        backgroundColor: Theme.cream2,
                                        textColor: Theme.brown,
                                        text: "Quiz"
                                    )
                                    .transition(.scale)
                                } else {
                                    Image("LockedButton")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 48)
                                        .transition(.scale)
                                }
                            }

                            ButtonStyle(
                                action: {
//                                    sound.play("bubble.mp3")
                                    presenter.playStory(id: presenter.expandedStoryID!)
                                },
                                backgroundColor: Theme.brown,
                                textColor: Theme.cream2,
                                text: "Start"
                            )
                            .transition(.scale)
                        }
                    }
                    
                }
                .padding(.trailing, 40)
                .frame(width: presenter.isExpanded ? 930 : 460, height: presenter.isExpanded ? 520 : 515)
                .background(Theme.storyCardExpanded)
                .clipShape(RoundedRectangle(cornerRadius: 39))
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 0)
                
                VStack {
                    ZStack {
                        
                        Image(story.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: presenter.isExpanded ? 415 : 400)
                            .clipShape(.rect(cornerRadius: 15))
                    }
                    .cornerRadius(28)
                    .offset(x: presenter.isExpanded ? -215 : 0)
                    
                    if !presenter.isExpanded {
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
                guard presenter.isActive else { return }

                if !presenter.isExpanded {
//                    sound.play("bubble.mp3")
                    withAnimation(Theme.easeOutBack) {
                        presenter.expandedStoryID = story.id
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
            ExpandableCard(story: Story(id:"texting", title: "WiFi", icon: "StoryCard-2", description: "Ever wonder how a text message from a phone reaches a laptop without any wires? It’s a idk"))
        }
    }
    return PreviewWrapper()
}
