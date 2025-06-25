//
//  LandingEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 6/15/25.
//

import Foundation

struct LandingEffect {
    static func handle(intent: LandingAction.Intent, state: LandingState, router: AppRouter) async -> LandingAction.Result? {
        switch intent {
        case .login:
            return await handleLogin(state: state)
        case .appleLoginTapped:
            return await handleAppleLogin()
        case .kakaoLoginTapped:
            return await handleKakaoLogin()
        case .registerTapped:
            await MainActor.run {
                router.navigate(to: .register)
            }
            return nil
        default:
            return nil
        }
    }

    private static func handleLogin(state: LandingState) async -> LandingAction.Result {
        let request = LoginRequest(
            email: state.email,
            password: state.password,
            deviceToken: ""
        )

        do {
            let result = try await NetworkManager.shared.fetch(
                UserRouter.login(request: request),
                successType: LoginResponse.self,
                failureType: CommonMessageResponse.self
            )

            if let success = result.success {
                return .loginSuccess(
                    accessToken: success.accessToken,
                    refreshToken: success.refreshToken,
                    userID: success.userId,
                    message: "로그인 성공!"
                )
            } else if let failure = result.failure {
                return .loginFailed(failure.message)
            } else {
                return .loginFailed("알 수 없는 로그인 오류 발생")
            }
        } catch {
            return .loginFailed("로그인 실패: \(error.localizedDescription)")
        }
    }

    private static func handleAppleLogin() async -> LandingAction.Result {
        AppleLoginManager.shared.setDeviceToken("temp-device-token")

        do {
            let request = try await AppleLoginManager.shared.login()
            let result = try await NetworkManager.shared.fetch(
                UserRouter.loginWithApple(request: request),
                successType: LoginResponse.self,
                failureType: CommonMessageResponse.self
            )

            if let success = result.success {
                return .appleLoginSuccess(
                    accessToken: success.accessToken,
                    refreshToken: success.refreshToken,
                    userID: success.userId,
                    message: "Apple 로그인 성공"
                )
            } else if let failure = result.failure {
                return .appleLoginFailed(failure.message)
            } else {
                return .appleLoginFailed("Apple 로그인 중 알 수 없는 오류 발생")
            }
        } catch {
            return .appleLoginFailed("Apple 로그인 실패: \(error.localizedDescription)")
        }
    }

    private static func handleKakaoLogin() async -> LandingAction.Result {
        // TODO: 카카오 로그인 구현
        print("카카오 로그인 처리")

        // 임시 구현 (실제로는 KakaoLoginManager 사용)
        do {
            // 카카오 로그인 로직이 구현되면 여기에 추가
            // let request = try await KakaoLoginManager.shared.login()
            // let result = try await NetworkManager.shared.fetch(...)

            return .kakaoLoginFailed("카카오 로그인이 아직 구현되지 않았습니다.")
        }
    }
}
