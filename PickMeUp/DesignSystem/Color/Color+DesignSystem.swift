//
//  Color+DesignSystem.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

public extension Color {
    /// HEX 문자열을 기반으로 Color 생성 (예: #FFFFFF 또는 FFFFFF)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: Double
        switch hex.count {
        case 6: // RGB (24-bit)
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            r = 1
            g = 1
            b = 1
        }

        self.init(red: r, green: g, blue: b)
    }
}

public extension Color {
    static let blackSprout = Color(hex: "D7A86E")
    static let deepSprout = Color(hex: "E5C9A3")
    static let brightSprout = Color(hex: "F6EEE3")
    static let brightForsythia = Color(hex: "FFB3A7")

    static let gray0   = Color(hex: "FFFFFF")
    static let gray15  = Color(hex: "F9F9F9")
    static let gray30  = Color(hex: "EAEAEA")
    static let gray45  = Color(hex: "D8D6D7")
    static let gray60  = Color(hex: "ABABAE")
    static let gray75  = Color(hex: "6A6A6E")
    static let gray90  = Color(hex: "434347")
    static let gray100 = Color(hex: "0B0B0B")
}
