//
//  LandingViewModel.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import AuthenticationServices
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

    private func handleAppleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()

        state.isLoading = true
        state.loginErrorMessage = nil
    }

    private func loginWithAppleCredential(_ credential: ASAuthorizationAppleIDCredential) {
        guard
            let tokenData = credential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8)
        else {
            self.state.loginErrorMessage = "ID 토큰이 유효하지 않습니다."
            self.state.isLoading = false
            return
        }

        print("🔐 [AppleLogin] idToken: \(idToken)")
        print("📱 [AppleLogin] deviceToken: your-device-token")
        print("🪪 [AppleLogin] user: \(credential.user)")

        let request = AppleLoginRequest(
            idToken: idToken,
            deviceToken: "your-device-token",
            nick: credential.user
        )

        Task {
            do {
                let (status, success, failure) = try await NetworkManager.shared.fetch(
                    UserRouter.loginWithApple(request: request),
                    successType: LoginResponse.self,
                    failureType: CommonMessageResponse.self
                )

                print("🌐 [Server Response] statusCode: \(status)")
                if let success = success {
                    print("✅ [Server Response] accessToken: \(success.accessToken)")
                    print("✅ [Server Response] refreshToken: \(success.refreshToken)")
                } else if let failure = failure {
                    print("❌ [Server Response] error: \(failure.message)")
                }

                await MainActor.run {
                    if let success = success {
                        TokenManager.shared.save(success.accessToken, for: .accessToken)
                        TokenManager.shared.save(success.refreshToken, for: .refreshToken)
                        TokenManager.shared.printStoredTokens()

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
                print("💥 [Error] Apple 로그인 네트워크 실패: \(error.localizedDescription)")
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

extension LandingViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            loginWithAppleCredential(credential)
        } else {
            state.loginErrorMessage = "Apple 로그인 정보가 유효하지 않습니다."
            state.isLoading = false
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        state.loginErrorMessage = "Apple 로그인 실패: \(error.localizedDescription)"
        state.isLoading = false
    }
}

extension LandingViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
    }
}


extension LandingViewModel {
    func handleAppleLoginResult(_ result: Result<ASAuthorization, Error>) {
        state.isLoading = true
        state.loginErrorMessage = nil

        switch result {
        case .success(let authorization):
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8)
            else {
                state.loginErrorMessage = "ID 토큰이 유효하지 않습니다."
                state.isLoading = false
                return
            }

            let fullName = credential.fullName
            let nickname = [fullName?.familyName, fullName?.givenName].compactMap { $0 }.joined()
            let deviceToken = "your-device-token" // 실제 푸시 토큰으로 교체

            let request = AppleLoginRequest(idToken: idToken, deviceToken: deviceToken, nick: nickname)

            Task {
                do {
                    let (_, success, failure) = try await NetworkManager.shared.fetch(
                        UserRouter.loginWithApple(request: request),
                        successType: LoginResponse.self,
                        failureType: CommonMessageResponse.self
                    )

                    await MainActor.run {
                        if let success = success {
                            TokenManager.shared.save(success.accessToken, for: .accessToken)
                            TokenManager.shared.save(success.refreshToken, for: .refreshToken)
                            TokenManager.shared.printStoredTokens()

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
                    await MainActor.run {
                        state.loginErrorMessage = "Apple 로그인 실패: \(error.localizedDescription)"
                    }
                }

                await MainActor.run { state.isLoading = false }
            }

        case .failure(let error):
            state.loginErrorMessage = "Apple 로그인 실패: \(error.localizedDescription)"
            state.isLoading = false
        }
    }
}
