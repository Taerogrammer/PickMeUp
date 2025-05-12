//
//  RegisterState.swift
//  PickMeUp
//
//  Created by 김태형 on 5/12/25.
//

import Foundation

struct RegisterState: Equatable {
    var email: String = ""
    var didRequestEmailValidation: Bool = false
    var emailValidationFeedback: String? = nil
    var isEmailValid: Bool = false

    var nickname: String = ""
    var nicknameValidationMessage: String? = nil
    var isNicknameValid: Bool = false

    var password: String = ""
    var passwordValidationMessage: String? = nil
    var isPasswordValid: Bool = false

    var isFormValid: Bool = false

    /// ✅ 사용자에게 보여줄 이메일 메시지
    var emailValidationMessage: String? {
        if !didRequestEmailValidation {
            return "이메일 인증을 진행해주세요"
        }
        if isEmailValid {
            return "이메일 인증이 완료되었습니다"
        }
        return emailValidationFeedback
    }

    var isPasswordVisible: Bool = false
}
