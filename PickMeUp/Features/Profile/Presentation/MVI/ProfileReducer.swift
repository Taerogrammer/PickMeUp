//
//  ProfileReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import Foundation

struct ProfileReducer {
    func reduce(state: inout ProfileState, action: ProfileAction.Intent) {
        switch action {
        case .onAppear:
            state.isLoading = true
            state.errorMessage = nil

        case .loadProfileImage:
            break

        case .editProfileTapped:
            state.isEditing = true
        }
    }

    func reduce(state: inout ProfileState, result: ProfileAction.Result) {
        switch result {
        case .profileLoaded(let user):
            state.user = user
            state.profile = user.toEntity()
            state.isLoading = false
            state.errorMessage = nil

        case .profileLoadFailed(let message):
            state.isLoading = false
            state.errorMessage = message

        case .profileImageLoaded(let image):
            state.profileImage = image

        case .profileImageLoadFailed(let error):
            state.profileImage = nil
            print("❌ 프로필 이미지 로딩 실패: \(error)")
        }
    }
}
