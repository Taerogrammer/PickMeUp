//
//  ProfileIntent.swift
//  PickMeUp
//
//  Created by 김태형 on 5/28/25.
//

import Foundation

enum ProfileIntent {
    case onAppear
    case fetchProfile(MeProfileResponse)
    case fetchFailed(String)
    case editProfileTapped
}
