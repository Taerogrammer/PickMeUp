//
//  LandingViewModel.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI
import Combine

final class LandingViewModel: NSObject, ObservableObject {
    @Published var state: LandingState
    @Published var resultMessage: String?

    private let router: AppRouter

    init(initialState: LandingState = LandingState(), router: AppRouter) {
        self.state = initialState
        self.router = router
    }

    func handleIntent(_ intent: LandingIntent) {
        switch intent {
        case .updateEmail(let email):
            state.email = email
        case .updatePassword(let password):
            state.password = password
        case .togglePasswordVisibility:
            state.isPasswordVisible.toggle()
        case .login:
            login()
        case .registerTapped:
            router.navigate(to: .register)
        case .appleLoginTapped:
            print("애플 로그인 처리")
            handleAppleLogin()
        case .kakaoLoginTapped:
            print("카카오 로그인 처리")
        }
    }

    private func login() {
        state.isLoading = true
        state.loginErrorMessage = nil
        let email = state.email
        let password = state.password
        let deviceToken = "" // 추후 실제 값으로 대체
        let request = LoginRequest(email: email, password: password, deviceToken: deviceToken)

        Task {
            do {
                let result = try await NetworkManager.shared.fetch(
                    UserRouter.login(request: request),
                    successType: LoginResponse.self,
                    failureType: CommonMessageResponse.self
                )

                await MainActor.run {
                    if let success = result.success {
                        KeychainManager.shared.save(key: TokenType.accessToken.rawValue, value: success.accessToken)
                        KeychainManager.shared.save(key: TokenType.refreshToken.rawValue, value: success.refreshToken)
                        // 로그인 성공 시 홈 화면으로 이동
                        router.navigate(to: .home)
                        resultMessage = "로그인 성공!"
                        state.loginErrorMessage = nil
                    } else if let failure = result.failure {
                        state.loginErrorMessage = failure.message
                    } else {
                        state.loginErrorMessage = "로그인 중 알 수 없는 오류가 발생했습니다."
                    }
                }
            } catch {
                await MainActor.run {
                    state.loginErrorMessage = "로그인 실패: \(error.localizedDescription)"
                }
            }
            await MainActor.run { state.isLoading = false }
        }
    }

    private func handleAppleLogin() {
        state.isLoading = true
        state.loginErrorMessage = nil

        AppleLoginManager.shared.setDeviceToken("hard-coding-device-token")

        Task {
            do {
                let request = try await AppleLoginManager.shared.login()
                let (status, success, failure) = try await NetworkManager.shared.fetch(
                    UserRouter.loginWithApple(request: request),
                    successType: LoginResponse.self,
                    failureType: CommonMessageResponse.self
                )

                await MainActor.run {
                    if let success = success {
                        KeychainManager.shared.save(key: TokenType.accessToken.rawValue, value: success.accessToken)
                        KeychainManager.shared.save(key: TokenType.refreshToken.rawValue, value: success.refreshToken)

                        router.navigate(to: .home)
                        resultMessage = "Apple 로그인 성공!"
                        state.loginErrorMessage = nil
                    } else if let failure = failure {
                        state.loginErrorMessage = failure.message
                    } else {
                        state.loginErrorMessage = "Apple 로그인 중 알 수 없는 오류가 발생했습니다."
                    }
                }
            } catch {
                print("💥 [Error] Apple 로그인 실패: \(error.localizedDescription)")
                await MainActor.run {
                    state.loginErrorMessage = "Apple 로그인 실패: \(error.localizedDescription)"
                }
            }

            await MainActor.run {
                state.isLoading = false
            }
        }
    }
}
