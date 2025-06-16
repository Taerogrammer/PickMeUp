//
//  LandingState.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import Foundation

struct LandingState {
    var email: String = ""
    var password: String = ""
    var isPasswordVisible: Bool = false
    var isShowingRegister: Bool = false
    var loginErrorMessage: String? = nil
    var successMessage: String? = nil

    var isLoading: Bool = false
    var isLoginLoading: Bool = false
    var isAppleLoginLoading: Bool = false
    var isKakaoLoginLoading: Bool = false
}
