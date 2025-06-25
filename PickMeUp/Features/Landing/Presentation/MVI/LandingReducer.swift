//
//  LandingReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 6/15/25.
//

import Foundation

struct LandingReducer {
    static func reduce(state: inout LandingState, intent: LandingAction.Intent) {
        switch intent {
        case .updateEmail(let email):
            state.email = email
            state.loginErrorMessage = nil
        case .updatePassword(let password):
            state.password = password
            state.loginErrorMessage = nil
        case .togglePasswordVisibility:
            state.isPasswordVisible.toggle()
        case .login:
            state.isLoginLoading = true
            state.loginErrorMessage = nil
        case .registerTapped: break
        case .appleLoginTapped:
            state.isAppleLoginLoading = true
            state.loginErrorMessage = nil
        case .kakaoLoginTapped:
            state.isKakaoLoginLoading = true
            state.loginErrorMessage = nil
        }

        state.isLoading = state.isLoginLoading || state.isAppleLoginLoading || state.isKakaoLoginLoading
    }

    static func reduce(state: inout LandingState, result: LandingAction.Result, appLaunchState: AppLaunchState) {
        switch result {
        case .loginSuccess(let accessToken, let refreshToken, let userID, _):
            state.isLoginLoading = false
            state.loginErrorMessage = nil

            KeychainManager.shared.save(key: KeychainType.accessToken.rawValue, value: accessToken)
            KeychainManager.shared.save(key: KeychainType.refreshToken.rawValue, value: refreshToken)
            KeychainManager.shared.save(key: KeychainType.userID.rawValue, value: userID)

            appLaunchState.isSessionValid = true

        case .loginFailed(let error):
            state.isLoginLoading = false
            state.loginErrorMessage = error

        case .appleLoginSuccess(let accessToken, let refreshToken, let userID, _):
            state.isAppleLoginLoading = false
            state.loginErrorMessage = nil

            KeychainManager.shared.save(key: KeychainType.accessToken.rawValue, value: accessToken)
            KeychainManager.shared.save(key: KeychainType.refreshToken.rawValue, value: refreshToken)
            KeychainManager.shared.save(key: KeychainType.userID.rawValue, value: userID)

            appLaunchState.isSessionValid = true

        case .appleLoginFailed(let error):
            state.isAppleLoginLoading = false
            state.loginErrorMessage = error

        case .kakaoLoginSuccess(let accessToken, let refreshToken, let userID, _):
            state.isKakaoLoginLoading = false
            state.loginErrorMessage = nil

            KeychainManager.shared.save(key: KeychainType.accessToken.rawValue, value: accessToken)
            KeychainManager.shared.save(key: KeychainType.refreshToken.rawValue, value: refreshToken)
            KeychainManager.shared.save(key: KeychainType.userID.rawValue, value: userID)

            appLaunchState.isSessionValid = true

        case .kakaoLoginFailed(let error):
            state.isKakaoLoginLoading = false
            state.loginErrorMessage = error
        }
        state.isLoading = state.isLoginLoading || state.isAppleLoginLoading || state.isKakaoLoginLoading
    }
}
