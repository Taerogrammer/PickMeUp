//
//  ProfileReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import Foundation

struct ProfileReducer {
    let router: AppRouter

    func reduce(state: inout ProfileState, intent: ProfileIntent) {
        switch intent {
        case .fetchProfile(let user):
            state.user = user
            state.profile = user.toEntity()

        case .fetchFailed(let message):
            state.errorMessage = message

        case .editProfileTapped:
            if let profile = state.profile {
                router.navigate(to: .editProfile(user: profile))
            }

        case .onAppear:
            break // handled by Effect
        }
    }
}
