//
//  RegisterStore.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import Foundation

final class RegisterStore: ObservableObject {
    @Published private(set) var state: RegisterState
    private let validator: RegisterValidator
    private let router: AppRouter

    init(state: RegisterState = .init(), router: AppRouter, validator: RegisterValidator = .init()) {
        self.state = state
        self.validator = validator
        self.router = router
    }

    func send(_ intent: RegisterIntent) {
        // 1차 동기 Reducer 적용
        RegisterReducer.reduce(state: &state, intent: intent, validator: validator)

        // 2차 비동기 Effect → 결과에 따라 추가 Reducer 실행
        Task {
            if let effect = await RegisterEffect.handle(intent: intent, state: state, validator: validator) {
                await MainActor.run {
                    effect(&self.state)
                    RegisterReducer.reduce(state: &self.state, intent: intent, validator: validator)
                }
            }
        }
    }

    func resetNavigation() {
        router.reset()
    }

    func clearAlert() {
        state.alertMessage = nil
    }
}
