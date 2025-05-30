//
//  EditProfileState.swift
//  PickMeUp
//
//  Created by 김태형 on 5/29/25.
//

import Foundation

struct ProfileEditState {
    var profile: ProfileEntity

    var isSaving: Bool = false
    var errorMessage: String? = nil

    var isNickValid: Bool {
        let trimmed = profile.nick.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }

        let forbiddenCharacters = CharacterSet(charactersIn: ".,?*-@")
        return trimmed.rangeOfCharacter(from: forbiddenCharacters) == nil
    }

    var isSaveButtonEnabled: Bool {
        isNickValid && !profile.phone.isEmpty
    }


    init(profile: ProfileEntity = ProfileEntity(nick: "", email: "", phone: "", profileImageURL: nil)) {
        self.profile = profile
    }
}
