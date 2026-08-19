//
//  QuizQuestionCatalog.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 19/08/26.
//

import Foundation

enum QuizQuestionCatalog {
    static let all: [Question] = [
        Question(
            text: "What can you use to connect your device to Wi-Fi?",
            options: ["Router", "Computer", "Cable", "Speaker"],
            correctAnswerIndex: 0
        ),
        Question(
            text: "What happens when you send a message online?",
            options: ["Your phone prints the message", "Your message stays inside your phone", "Your message travels through networks to reach the other person", "Your message disappears"],
            correctAnswerIndex: 2
        ),
        Question(
            text: "How does a message travel through the internet?",
            options: ["Your device → Router → Internet → Receiver’s Router → Receiver’s device", "Your device → Receiver’s device → Router → Internet", "Your device → Router → Receiver’s device → Internet", "Your device → Internet → Your router → Receiver’s device"],
            correctAnswerIndex: 0
        ),
        Question(
            text: "What happens when your device is outside the router’s range?",
            options: ["Your device connects faster", "Your device may lose its Wi-Fi connection", "The router moves closer to your device", "Your device gets a stronger signal"],
            correctAnswerIndex: 1
        ),
        Question(
            text: "What happens when an internet signal goes through a wall?",
            options: ["The signal can become weaker", "The signal becomes stronger", "The signal disappears forever", "The signal changes into a sound"],
            correctAnswerIndex: 0
        )
    ]
}
