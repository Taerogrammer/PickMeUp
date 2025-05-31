//
//  ProfileReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import Foundation

struct ProfileReducer {
    func reduce(state: inout ProfileState, intent: ProfileIntent) {
        switch intent {
        case .fetchProfile(let user):
            state.user = user
            state.profile = user.toEntity()

        case .fetchFailed(let message):
            state.errorMessage = message

        case .editProfileTapped:
            state.isEditing = true

        case .onAppear:
            break
        }
    }
}
