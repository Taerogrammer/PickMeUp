//
//  ProfileState.swift
//  PickMeUp
//
//  Created by 김태형 on 5/28/25.
//

import Foundation

struct ProfileState {
    var user: MeProfileResponse
    var profile: ProfileEntity?
    var isEditing: Bool = false
    var errorMessage: String?
}
