//
//  ProfileEditReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import SwiftUI

struct ProfileEditReducer {
    func reduce(state: inout ProfileEditState, intent: ProfileEditIntent) {
        switch intent {
        case .updateProfile(let profile):
            state.profile = profile

        case .toggleImagePicker(let show):
            state.showImagePicker = show

        case .updateSelectedImage(let image):
            state.selectedImage = image

        case .uploadImage:
            state.imageUploading = true
            state.errorMessage = nil

        case .uploadImageSuccess(let path):
            state.imageUploading = false
            state.profile.profileImageURL = path

        case .uploadImageFailure(let message):
            state.imageUploading = false
            state.errorMessage = message

        case .saveTapped:
            state.isSaving = true
            state.errorMessage = nil

        case .saveSuccess:
            state.isSaving = false

        case .saveFailure(let error):
            state.isSaving = false
            state.errorMessage = error.message

        case .loadRemoteImage(let image):
            state.remoteImage = image

        case .loadRemoteImageFailed(let error):
            state.errorMessage = error
        }
    }
}

