//
//  LandingStore.swift
//  PickMeUp
//
//  Created by 김태형 on 6/15/25.
//

import Foundation

final class LandingStore: ObservableObject {
    @Published private(set) var state: LandingState

    private let router: AppRouter
    private let appLaunchState: AppLaunchState

    init(initialState: LandingState = LandingState(), router: AppRouter, appLaunchState: AppLaunchState) {
        self.state = initialState
        self.router = router
        self.appLaunchState = appLaunchState
    }

    func send(_ intent: LandingAction.Intent) {
        // 1차: Intent에 대한 즉시 상태 업데이트
        LandingReducer.reduce(state: &state, intent: intent)

        // 특별 처리: 네비게이션
        if case .registerTapped = intent {
            router.navigate(to: .register)
        }

        Task {
            if let result = await LandingEffect.handle(intent: intent, state: state) {
                await handleResult(result)
            }
        }
    }

    @MainActor
    private func handleResult(_ result: LandingAction.Result) {
        LandingReducer.reduce(state: &state, result: result, appLaunchState: appLaunchState)

        // 성공 메시지 설정
        switch result {
        case .loginSuccess(_, _, let message):
            state.successMessage = message
        case .appleLoginSuccess(_, _, let message):
            state.successMessage = message
        case .kakaoLoginSuccess(_, _, let message):
            state.successMessage = message
        default:
            break
        }
    }

    func dismissRegister() {
        state.isShowingRegister = false
    }
}
