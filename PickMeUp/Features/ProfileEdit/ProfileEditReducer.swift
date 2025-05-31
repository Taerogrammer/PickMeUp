//
//  ProfileEditReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import Foundation

struct ProfileEditReducer {
    func reduce(state: inout ProfileEditState, intent: ProfileEditIntent) {
        switch intent {
        case .updateProfile(let newProfile):
            state.profile = newProfile

        case .saveTapped:
            state.isSaving = true
            state.errorMessage = nil

        case .saveSuccess:
            state.isSaving = false

        case .saveFailure(let error):
            state.isSaving = false
            state.errorMessage = error.message
        }
    }
}
