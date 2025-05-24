//
//  LandingViewModel.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI
import Combine

final class LandingViewModel: ObservableObject {
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
        case .kakaoLoginTapped:
            print("카카오 로그인 처리")
        case .toggleAutoLogin(let enabled):
            state.isAutoLoginEnabled = enabled
            UserDefaultsManager.isAutoLoginEnabled = enabled
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
                print("[DEBUG] result: \(result)")
                print("[DEBUG] success: \(String(describing: result.success))")
                print("[DEBUG] failure: \(String(describing: result.failure))")
                await MainActor.run {
                    if let success = result.success {
                        TokenManager.shared.save(success.accessToken, for: .accessToken)
                        TokenManager.shared.save(success.refreshToken, for: .refreshToken)
                        TokenManager.shared.printStoredTokens()
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
}
