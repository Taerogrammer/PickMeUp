//
//  RegisterReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import Foundation

struct RegisterReducer {
    static func reduce(state: inout RegisterState, intent: RegisterAction.Intent, validator: RegisterValidator) {
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
        case .validateEmail, .submit:
            break // handled in effect
        }
        validateForm(&state, validator: validator)
    }

    private static func validateForm(_ state: inout RegisterState, validator: RegisterValidator) {
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
}
