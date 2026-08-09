//
//  StoryCatalog.swift
//  NectAr
//
//  Created by abr on 01/08/26.
//

import Foundation

enum StoryCatalog {
    static let all: [Story] = [
        Story(id: "texting", title: "Texting each device", icon: "message.fill"),
        Story(id: "streaming", title: "Streaming YouTube", icon: "play.rectangle.fill"),
        Story(id: "iot", title: "Internet of Things", icon: "ipod.and.applewatch"),
        Story(id: "game", title: "Gaming", icon: "gamecontroller.circle.fill"),
        Story(id: "browsing", title: "Browsing the web", icon: "laptopcomputer")
    ]
}
