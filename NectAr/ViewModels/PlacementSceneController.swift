//
//  PlacementSceneController.swift
//  NectAr
//
//  Created by Putri Aziza Mufva on 07/08/26.
//

import SwiftUI

@Observable
class PlacementSceneController {
    
    var selectedDeviceKind: DeviceKind = .deviceA
    var isComplete: Bool = false
    var isPlaying: Bool = false
    
    var buttonIconName: String {
        if isComplete {
            if isPlaying {
                return "stop.circle.fill"
            } else {
                return "play.circle.fill"
            }
        } else {
            return "plus.circle.fill"
        }
    }
    
    var buttonColor: Color {
            if isComplete {
                if isPlaying {
                    return .red // stop
                } else {
                    return .green// play
                }
            } else {
                return .white // preparation
            }
        }
    
    func handleButtonTap() {
        if isComplete {
            isPlaying.toggle()
        } else {
            isComplete = true
        }
    }
}
