//
//  AppPhase.swift
//  NectAr
//
//  Created by abr on 01/08/26.
//

import Foundation

enum AppPhase {
    case splash
    case onboarding
    case menu
    case ar(Story.ID)
    case quiz
}
