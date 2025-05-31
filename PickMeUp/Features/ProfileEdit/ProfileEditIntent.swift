//
//  EditProfileIntent.swift
//  PickMeUp
//
//  Created by 김태형 on 5/29/25.
//

import SwiftUI

enum ProfileEditIntent {
    case updateProfile(ProfileEntity)
    case toggleImagePicker(Bool)
    case updateSelectedImage(UIImage)
    case uploadImage
    case uploadImageSuccess(String)
    case uploadImageFailure(String)
    case saveTapped
    case saveSuccess
    case saveFailure(APIError)
}
