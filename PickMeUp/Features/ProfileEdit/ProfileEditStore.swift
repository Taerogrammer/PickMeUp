//
//  ProfileEditStore.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import Combine
import Foundation

final class ProfileEditStore: ObservableObject {
    @Published private(set) var state: ProfileEditState
    private let reducer: ProfileEditReducer
    private let effect: ProfileEditEffect
    private let router: AppRouter

    init(
        state: ProfileEditState,
        reducer: ProfileEditReducer,
        effect: ProfileEditEffect,
        router: AppRouter
    ) {
        self.state = state
        self.reducer = reducer
        self.effect = effect
        self.router = router
    }

    func send(_ intent: ProfileEditIntent) {
        switch intent {
        case .saveTapped:
            reducer.reduce(state: &state, intent: .saveTapped)

            Task {
                let result = await effect.saveProfile(profile: state.profile)
                await MainActor.run {
                    switch result {
                    case .success:
                        reducer.reduce(state: &state, intent: .saveSuccess)
                        router.pop()
                    case .failure(let error):
                        reducer.reduce(state: &state, intent: .saveFailure(error))
                    }
                }
            }

        case .updateProfile:
            reducer.reduce(state: &state, intent: intent)

        case .saveSuccess, .saveFailure:
            reducer.reduce(state: &state, intent: intent)
        }
    }
}
