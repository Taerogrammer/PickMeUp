//
//  LandingState.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import Foundation

/// 뷰가 관찰하는 상태 정의
struct LandingState {
    var email: String = ""
    var password: String = ""
    var isPasswordVisible: Bool = false
    var isShowingRegister: Bool = false
    var loginErrorMessage: String? = nil
    var isLoading: Bool = false
    var isAutoLoginEnabled: Bool = UserDefaultsManager.isAutoLoginEnabled
}
