//
//  LandingViewModel.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI
import Combine

final class LandingViewModel: ObservableObject {
    @Published var state: LandingState
    @Published var resultMessage: String?

    private let router: AppRouter

    init(initialState: LandingState = LandingState(), router: AppRouter) {
        self.state = initialState
        self.router = router
    }

    func handleIntent(_ intent: LandingIntent) {
        switch intent {
        case .registerTapped:
            router.navigate(to: .register)
        case .appleLoginTapped:
            print("애플 로그인 처리")
        case .kakaoLoginTapped:
            print("카카오 로그인 처리")
        }
    }
}
