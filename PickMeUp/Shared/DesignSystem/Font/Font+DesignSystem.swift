//
//  Font+DesignSystem.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

public extension Font {

    // MARK: - Pretendard
    static let pretendardTitle1   = Font.pretendard(20, weight: .bold)
    static let pretendardBody1    = Font.pretendard(16, weight: .medium)
    static let pretendardBody2    = Font.pretendard(14, weight: .medium)
    static let pretendardBody3    = Font.pretendard(13, weight: .medium)
    static let pretendardCaption1 = Font.pretendard(12, weight: .regular)
    static let pretendardCaption2 = Font.pretendard(10, weight: .regular)
    static let pretendardCaption3 = Font.pretendard(8, weight: .regular)

    // MARK: - Jalnan Gothic
    static let jalnanTitle1   = Font.custom("JalnanGothic", size: 24)
    static let jalnanBody1    = Font.custom("JalnanGothic", size: 20)
    static let jalnanCaption1 = Font.custom("JalnanGothic", size: 14)

    // Pretendard 기본 접근자
    static func pretendard(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .bold:
            return .custom("Pretendard-Bold", size: size)
        case .medium:
            return .custom("Pretendard-Medium", size: size)
        case .regular:
            return .custom("Pretendard-Regular", size: size)
        default:
            return .custom("Pretendard-Regular", size: size)
        }
    }
}
