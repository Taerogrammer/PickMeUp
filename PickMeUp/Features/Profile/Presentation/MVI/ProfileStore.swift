//
//  ProfileStore.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import Foundation

final class ProfileStore: ObservableObject {
    @Published private(set) var state: ProfileState
    private let effect: ProfileEffect
    private let reducer: ProfileReducer
    let router: AppRouter

    init(
        state: ProfileState,
        effect: ProfileEffect,
        reducer: ProfileReducer,
        router: AppRouter
    ) {
        self.state = state
        self.effect = effect
        self.reducer = reducer
        self.router = router
    }

    @MainActor
    func send(_ action: ProfileAction.Intent) {
        reducer.reduce(state: &state, action: action)
        effect.handle(action, store: self)
    }

    @MainActor
    func send(_ result: ProfileAction.Result) {
        reducer.reduce(state: &state, result: result)
    }
}
