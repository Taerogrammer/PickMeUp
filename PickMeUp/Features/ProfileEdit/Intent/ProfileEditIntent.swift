//
//  EditProfileIntent.swift
//  PickMeUp
//
//  Created by 김태형 on 5/29/25.
//

import Foundation

enum ProfileEditIntent {
    case updateNick(String)
    case updateEmail(String)
    case updatePhone(String)
    case saveChanges
}
