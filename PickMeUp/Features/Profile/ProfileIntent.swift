//
//  ProfileIntent.swift
//  PickMeUp
//
//  Created by 김태형 on 5/28/25.
//

import SwiftUI

enum ProfileIntent {
    case onAppear
    case fetchProfile(MeProfileResponse)
    case fetchFailed(String)

    case loadProfileImage(String)
    case profileImageLoaded(UIImage)
    case profileImageLoadFailed(String)

    case editProfileTapped
}
