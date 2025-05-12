//
//  RegisterViewModel.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import Combine
import Foundation

final class RegisterViewModel: ObservableObject {
    @Published var state: RegisterState
    let router: AppRouter
    private let validator: RegisterValidator

    init(initialState: RegisterState = RegisterState(), router: AppRouter, validator: RegisterValidator = .init()) {
        self.state = initialState
        self.router = router
        self.validator = validator
    }

    func handleIntent(_ intent: RegisterIntent) {
        switch intent {
        case .updateEmail(let email):
            if state.email != email {
                state.email = email
                state.didRequestEmailValidation = false
                state.emailValidationFeedback = nil
                state.isEmailValid = false
            }
        case .updateNickname(let nickname):
            state.nickname = nickname
        case .updatePassword(let password):
            state.password = password
        case .togglePasswordVisibility:
            state.isPasswordVisible.toggle()
        case .validateEmail:
            Task { await validateEmail() }
        case .submit:
            validateAndRegister()
        }
        validateForm()
    }

    private func validateForm() {
        state.isNicknameValid = validator.validateNicknameFormat(state.nickname)
        state.nicknameValidationMessage = state.nickname.isEmpty
            ? nil
            : (state.isNicknameValid ? nil : "닉네임에 . , ,, ?, *, -, @ 문자는 사용할 수 없습니다.")

        state.isPasswordValid = validator.validatePasswordFormat(state.password)
        state.passwordValidationMessage = state.password.isEmpty
            ? nil
            : (state.isPasswordValid ? nil : "비밀번호는 8자 이상, 영문, 숫자, 특수문자를 포함해야 합니다.")

        state.isFormValid = state.isEmailValid && state.isNicknameValid && state.isPasswordValid
    }

    private func validateEmail() async {
        await MainActor.run {
            state.didRequestEmailValidation = true
        }

        guard validator.validateEmailFormat(state.email) else {
            await MainActor.run {
                state.emailValidationFeedback = "이메일 형식이 유효하지 않습니다."
                state.isEmailValid = false
                validateForm()
            }
            return
        }

        do {
            let result = try await NetworkManager.shared.fetch(
                PickupRouter.validateEmail(email: state.email),
                successType: CommonMessageResponse.self,
                failureType: CommonMessageResponse.self
            )

            await MainActor.run {
                if let success = result.success {
                    state.isEmailValid = true
                    state.emailValidationFeedback = success.message
                } else if let failure = result.failure {
                    state.isEmailValid = false
                    state.emailValidationFeedback = failure.message
                } else {
                    state.isEmailValid = false
                    state.emailValidationFeedback = "이메일 중복 확인 중 알 수 없는 오류 발생."
                }
                validateForm()
            }

        } catch {
            await MainActor.run {
                state.emailValidationFeedback = "이메일 중복 확인 중 네트워크 오류 발생: \(error.localizedDescription)"
                state.isEmailValid = false
                validateForm()
            }
        }
    }

    private func validateAndRegister() {
        guard state.isFormValid else { return }

        Task {
            let request = JoinRequest(
                email: state.email,
                password: state.password,
                nick: state.nickname,
                phoneNum: "01012341234",
                deviceToken: ""
            )

            do {
                let result = try await NetworkManager.shared.fetch(
                    PickupRouter.join(request: request),
                    successType: JoinResponse.self,
                    failureType: CommonMessageResponse.self
                )

                await MainActor.run {
                    if let success = result.success {
                        print("가입 성공, 유저 ID: \(success.userId)")
                        print("AccessToken: \(success.accessToken)")
                        print("RefreshToken: \(success.refreshToken)")

                        state.alertMessage = "회원가입이 완료되었습니다."
                        state.isRegisterSuccess = true

                    } else if let failure = result.failure {
                        state.alertMessage = failure.message
                        state.isRegisterSuccess = false

                    } else {
                        state.alertMessage = "회원가입 중 알 수 없는 오류가 발생했습니다."
                        state.isRegisterSuccess = false
                    }
                }

            } catch {
                await MainActor.run {
                    state.alertMessage = "회원가입 중 네트워크 오류가 발생했습니다. 네트워크 상태를 확인해주세요."
                    state.isRegisterSuccess = false
                }
            }
        }
    }
}
