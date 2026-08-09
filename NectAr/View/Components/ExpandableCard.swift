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
    
    @Binding var expandedStoryID: Story.ID?
    
    var isExpanded: Bool {
        expandedStoryID == story.id
    }
    
    // animation
    let easeOutBack = Animation.timingCurve(0.175, 0.885, 0.32, 1.275, duration: 0.5)
    let easeInBack = Animation.timingCurve(0.6, -0.28, 0.735, 0.045, duration: 0.5)
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    if isExpanded {
                        Button(action: {
                            withAnimation(easeInBack) {
                                expandedStoryID = nil
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 65))
                                .foregroundColor(.gray)
                        }
                        .transition(.opacity)
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    if isExpanded {
                        Button(action: {
                            print("Play button tapped") // test
                        }) {
                            Text("Play")
                                .font(.title2.bold())
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        .transition(.opacity)
                    }
                }
            }
            .padding(24)
            
            .frame(width: isExpanded ? 1100 : 300, height: isExpanded ? 750 : 200)
            .background(Color(white: 0.9))
            .clipShape(RoundedRectangle(cornerRadius: 32))
            
            ZStack {
                Color.gray
                Image(story.icon)
                    .resizable()
                    .padding(75)
            }
            .frame(width: 475, height: 475)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .offset(x: isExpanded ? -220 : 0)
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
                story: Story(id:"texting", title: "Texting", icon: "AbeeIcon"),
                isActive: true,
                expandedStoryID: $mockExpandedID
            )
        }
    }
    return PreviewWrapper()
}
