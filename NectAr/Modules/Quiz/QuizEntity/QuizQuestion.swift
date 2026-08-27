//
//  QuizQuestion.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 18/08/26.
//

import Foundation

struct Question: Identifiable {
    let id = UUID()
    let text: String
    let options: [String]
    let correctAnswerIndex: Int
}
