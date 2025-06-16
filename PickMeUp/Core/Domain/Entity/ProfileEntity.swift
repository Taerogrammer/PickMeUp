//
//  ProfileEntity.swift
//  PickMeUp
//
//  Created by 김태형 on 5/30/25.
//

import Foundation

struct ProfileEntity: Equatable, Hashable {
    var nick: String
    var email: String
    var phone: String
    var profileImageURL: String?
}

extension ProfileEntity {
    func toRequest() -> MeProfileRequest {
        return MeProfileRequest(
            nick: self.nick,
            phoneNum: self.phone,
            profileImage: self.profileImageURL ?? ""
        )
    }
}
