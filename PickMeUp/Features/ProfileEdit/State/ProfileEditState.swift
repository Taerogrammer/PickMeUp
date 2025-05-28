//
//  EditProfileState.swift
//  PickMeUp
//
//  Created by 김태형 on 5/29/25.
//

import Foundation

struct ProfileEditState {
    var nick: String
    var email: String
    var phoneNum: String
    var isSaving: Bool = false
    var errorMessage: String? = nil
}
