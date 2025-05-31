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
    private let router: AppRouter

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

    func send(_ intent: ProfileIntent) {
        if case .onAppear = intent {
            effect.handleOnAppear(store: self)
        } else {
            reducer.reduce(state: &state, intent: intent)

            if case .editProfileTapped = intent,
               let profile = state.profile {
                router.navigate(to: .editProfile(user: profile))
            }
        }
    }
}
