//
//  RegisterIntent.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import Foundation

enum RegisterIntent {
    case updateEmail(String)
    case updateNickname(String)
    case updatePassword(String)
    case togglePasswordVisibility
    case validateEmail
    case submit
}
