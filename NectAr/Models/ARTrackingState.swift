//
//  ARTrackingState.swift
//  NectAr
//
//  Created by abr on 01/08/26.
//

import Foundation

enum TrackingFailureReason {
    case initializing
    case excessiveMotion
    case insufficientFeatures
    case relocalizing
    case noPlaneYet
}
