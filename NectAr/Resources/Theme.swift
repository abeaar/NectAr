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
    static let gold        = Color(hex: "FFB100")
    static let cream       = Color(hex: "FFFAF3")
    static let brown       = Color(hex: "3D2900")
    static let red         = Color(hex: "FF383C")
    static let green       = Color(hex: "1EFF00")

    // MARK: Neutral / text
    // ──────────────────────────────────────────
    static let textPrimary   = brown

    // MARK: Surfaces
    // ──────────────────────────────────────────
    static let background   = cream
    static let cardSurface  = gold
    static let stroke       = gold

    // MARK: Semantic / role-based aliases
    // ──────────────────────────────────────────
    static let accent       = gold
    static let accentSoft   = gold.opacity(0.15)
    static let buttonPrimary = brown

    // MARK: Icon buttons (Image 1)
    // ──────────────────────────────────────────
    static let iconGoldFill = gold
    static let iconStop     = red
    static let iconPlay     = green
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
