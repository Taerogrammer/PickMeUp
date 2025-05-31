//
//  EditProfileState.swift
//  PickMeUp
//
//  Created by 김태형 on 5/29/25.
//

import SwiftUI

enum ImageFormat {
    case jpg
    case jpeg
    case png
}

struct ProfileEditState {
    var profile: ProfileEntity
    var isSaving: Bool = false
    var errorMessage: String? = nil
    var showImagePicker: Bool = false
    var selectedImage: UIImage? = nil
    var imageUploading: Bool = false

    init(profile: ProfileEntity = ProfileEntity(nick: "", email: "", phone: "", profileImageURL: "")) {
        self.profile = profile
    }

    var isNickValid: Bool {
        let trimmed = profile.nick.trimmingCharacters(in: .whitespacesAndNewlines)
        let forbidden = CharacterSet(charactersIn: ".,?*-@")
        return !trimmed.isEmpty && trimmed.rangeOfCharacter(from: forbidden) == nil
    }

    var isSaveButtonEnabled: Bool {
        isNickValid && !profile.phone.isEmpty && !imageUploading
    }
}
