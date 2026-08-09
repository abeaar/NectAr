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
                return "StopButton"
            } else {
                return "PlayButton"
            }
        } else {
            return "PlusButton"
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
