//
//  LandingIntent.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import Foundation

/// 사용자 의도를 표현하는 Intent 정의
enum LandingIntent {
    case updateEmail(String)
    case updatePassword(String)
    case togglePasswordVisibility
    case login
    case registerTapped
    case appleLoginTapped
    case kakaoLoginTapped
    case toggleAutoLogin(Bool)
}
