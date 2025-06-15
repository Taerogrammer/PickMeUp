//
//  RegisterIntent.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import Foundation

enum RegisterAction {
    enum Intent {
        case updateEmail(String)
        case updateNickname(String)
        case updatePassword(String)
        case togglePasswordVisibility
        case validateEmail
        case submit
    }

    enum Result {
        case emailValidationCompleted((inout RegisterState) -> Void)
        case submitCompleted((inout RegisterState) -> Void)
    }
}
