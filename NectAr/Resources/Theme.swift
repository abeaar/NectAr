//
//  Theme.swift
//  NectAr
//
//  Created by Muhammad Fairuz Ismayana on 10/08/26.
//
import SwiftUI

enum Theme {

    // MARK: Brand colours
    // ──────────────────────────────────────────
    static let yellow      = Color(hex: "FFB100")
    static let cream       = Color(hex: "FFF4D9")
    static let brown       = Color(hex: "412800")


    // MARK: Neutral / text
    // ──────────────────────────────────────────
    static let textPrimary   = cream

    // MARK: Surfaces
    // ──────────────────────────────────────────
    static let background   = cream
    static let storyCardExpanded    = yellow
    static let stroke       = yellow

    // MARK: Semantic / role-based aliases
    // ──────────────────────────────────────────

}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >>  8) & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
