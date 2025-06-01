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
    var isEditing: Bool = false
    var errorMessage: String?
}
