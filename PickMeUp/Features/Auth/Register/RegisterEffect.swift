//
//  RegisterEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import Foundation

struct RegisterEffect {
    static func handle(intent: RegisterIntent, state: RegisterState, validator: RegisterValidator) async -> ((inout RegisterState) -> Void)? {
        switch intent {
        case .validateEmail:
            return await handleValidateEmail(state: state, validator: validator)
        case .submit:
            return await handleSubmit(state: state)
        default:
            return nil
        }
    }

    private static func handleValidateEmail(state: RegisterState, validator: RegisterValidator) async -> ((inout RegisterState) -> Void)? {
        return await withCheckedContinuation { continuation in
            Task {
                var update: (inout RegisterState) -> Void = { _ in }

                if !validator.validateEmailFormat(state.email) {
                    update = {
                        $0.emailValidationFeedback = "이메일 형식이 유효하지 않습니다."
                        $0.isEmailValid = false
                        $0.didRequestEmailValidation = true
                    }
                    continuation.resume(returning: update)
                    return
                }

                do {
                    let result = try await NetworkManager.shared.fetch(
                        UserRouter.validateEmail(request: EmailRequest(email: state.email)),
                        successType: CommonMessageResponse.self,
                        failureType: CommonMessageResponse.self
                    )

                    update = {
                        $0.didRequestEmailValidation = true
                        if let success = result.success {
                            $0.isEmailValid = true
                            $0.emailValidationFeedback = success.message
                        } else if let failure = result.failure {
                            $0.isEmailValid = false
                            $0.emailValidationFeedback = failure.message
                        } else {
                            $0.isEmailValid = false
                            $0.emailValidationFeedback = "이메일 중복 확인 중 알 수 없는 오류 발생."
                        }
                    }
                    continuation.resume(returning: update)
                } catch {
                    update = {
                        $0.didRequestEmailValidation = true
                        $0.isEmailValid = false
                        $0.emailValidationFeedback = "이메일 중복 확인 중 네트워크 오류 발생: \(error.localizedDescription)"
                    }
                    continuation.resume(returning: update)
                }
            }
        }
    }

    private static func handleSubmit(state: RegisterState) async -> ((inout RegisterState) -> Void)? {
        guard state.isFormValid else {
            return { $0.alertMessage = "입력값을 확인해주세요" }
        }

        let request = JoinRequest(
            email: state.email,
            password: state.password,
            nick: state.nickname,
            phoneNum: "01012341234",
            deviceToken: ""
        )

        do {
            let result = try await NetworkManager.shared.fetch(
                UserRouter.join(request: request),
                successType: JoinResponse.self,
                failureType: CommonMessageResponse.self
            )

            return {
                if let _ = result.success {
                    $0.alertMessage = "회원가입이 완료되었습니다."
                    $0.isRegisterSuccess = true
                } else if let failure = result.failure {
                    $0.alertMessage = failure.message
                    $0.isRegisterSuccess = false
                } else {
                    $0.alertMessage = "회원가입 중 알 수 없는 오류가 발생했습니다."
                    $0.isRegisterSuccess = false
                }
            }
        } catch {
            return {
                $0.alertMessage = "회원가입 중 네트워크 오류가 발생했습니다. 네트워크 상태를 확인해주세요."
                $0.isRegisterSuccess = false
            }
        }
    }
}
