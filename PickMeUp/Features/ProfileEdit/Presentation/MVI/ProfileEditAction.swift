//
//  EditProfileIntent.swift
//  PickMeUp
//
//  Created by 김태형 on 5/29/25.
//

import SwiftUI

enum ProfileEditAction {
    enum Intent {
        case updateProfile(ProfileEntity)
        case toggleImagePicker(Bool)
        case updateSelectedImage(UIImage)
        case uploadImage
        case saveTapped
    }

    enum Result {
        case uploadImageSuccess(String)
        case uploadImageFailure(String)
        case saveSuccess
        case saveFailure(APIError)
        case loadRemoteImage(UIImage)
        case loadRemoteImageFailed(String)
    }
}
