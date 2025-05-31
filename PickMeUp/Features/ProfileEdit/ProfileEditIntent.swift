//
//  EditProfileIntent.swift
//  PickMeUp
//
//  Created by 김태형 on 5/29/25.
//

import Foundation

enum ProfileEditIntent {
    case updateProfile(ProfileEntity)
    case saveTapped
    case saveSuccess
    case saveFailure(APIError)
}
