//
//  LandingViewModel.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI
import Combine

final class LandingViewModel: ObservableObject {
    @Published var isShowingRegister = false

    // 사용자 Intent를 명확하게 선언
    func handleIntent(_ intent: Intent) {
        switch intent {
        case .registerTapped:
            isShowingRegister = true
        case .appleLoginTapped:
            print("애플 로그인 처리")
        case .kakaoLoginTapped:
            print("카카오 로그인 처리")
        }
    }

    enum Intent {
        case registerTapped
        case appleLoginTapped
        case kakaoLoginTapped
    }
}
