//
//  EditProfileIntent.swift
//  PickMeUp
//
//  Created by 김태형 on 5/29/25.
//

import Foundation

enum ProfileEditIntent {
    case updateNick(String)
    case updatePhoneNum(String)
    case updateProfileImage(String)
    case saveTapped
}
