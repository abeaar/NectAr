//
//  StoryCatalog.swift
//  NectAr
//
//  Created by abr on 01/08/26.
//

import Foundation

enum StoryCatalog {
    static let all: [Story] = [
        Story(id: "wifi", title: "Wifi", icon: "StoryCard-1", description: "Ever wonder how a text message from a phone reaches a laptop without any wires? It’s all thanks to Wi-Fi! \n\nJump in to see the invisible data packages flying around your own room!"),
        Story(id: "streaming", title: "Streaming YouTube", icon: "StoryCard-2", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut."),
        Story(id: "iot", title: "Internet of Things", icon: "StoryCard-1", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut."),
        Story(id: "game", title: "Gaming", icon: "StoryCard-2", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut."),
        Story(id: "browsing", title: "Browsing the web", icon: "StoryCard-1", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut.")
    ]
}
