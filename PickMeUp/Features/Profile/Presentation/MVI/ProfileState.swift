//
//  ProfileState.swift
//  PickMeUp
//
//  Created by 김태형 on 5/28/25.
//

import SwiftUI

struct ProfileState {
    var user: MeProfileResponse
    var profile: ProfileEntity?
    var profileImage: UIImage? = nil
    var isLoading: Bool = false
    var isEditing: Bool = false
    var errorMessage: String?

    var hasProfileImage: Bool {
        return profileImage != nil
    }

    var displayName: String {
        return user.nick.isEmpty ? "사용자" : user.nick
    }

    var hasError: Bool {
        return errorMessage != nil
    }
}
