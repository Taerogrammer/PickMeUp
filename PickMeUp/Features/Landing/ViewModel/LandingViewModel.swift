//
//  LandingViewModel.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI
import Combine

final class LandingViewModel: ObservableObject {
    @Published private(set) var state: LandingState

    init(initialState: LandingState = LandingState()) {
        self.state = initialState
    }

    func handleIntent(_ intent: LandingIntent) {
        switch intent {
        case .registerTapped:
            state.isShowingRegister = true
        case .appleLoginTapped:
            print("애플 로그인 처리")
        case .kakaoLoginTapped:
            print("카카오 로그인 처리")
        }
    }
}
