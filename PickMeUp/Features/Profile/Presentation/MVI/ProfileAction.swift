//
//  ProfileIntent.swift
//  PickMeUp
//
//  Created by 김태형 on 5/28/25.
//

import SwiftUI

enum ProfileAction {
    enum Intent {
        case onAppear
        case loadProfileImage(String)
        case editProfileTapped
    }

    enum Result {
        case profileLoaded(MeProfileResponse)
        case profileLoadFailed(String)
        case profileImageLoaded(UIImage)
        case profileImageLoadFailed(String)
    }
}
