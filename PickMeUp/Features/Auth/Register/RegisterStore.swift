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

    func send(_ intent: RegisterAction.Intent) {
        RegisterReducer.reduce(state: &state, intent: intent, validator: validator)

        Task {
            if let effect = await RegisterEffect.handle(intent: intent, state: state, validator: validator) {
                await MainActor.run {
                    effect(&self.state)
                    RegisterReducer.reduce(state: &self.state, intent: intent, validator: self.validator)
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
