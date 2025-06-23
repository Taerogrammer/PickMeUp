//
//  LandingIntent.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import Foundation

enum LandingAction {
    enum Intent {
        case updateEmail(String)
        case updatePassword(String)
        case togglePasswordVisibility
        case login
        case registerTapped
        case appleLoginTapped
        case kakaoLoginTapped
    }

    enum Result {
        case loginSuccess(accessToken: String, refreshToken: String, userID: String, message: String)
        case loginFailed(String)
        case appleLoginSuccess(accessToken: String, refreshToken: String, userID: String, message: String)
        case appleLoginFailed(String)
        case kakaoLoginSuccess(accessToken: String, refreshToken: String, userID: String, message: String)
        case kakaoLoginFailed(String)
    }
}
