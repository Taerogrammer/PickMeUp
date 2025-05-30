//
//  ProfileEntity.swift
//  PickMeUp
//
//  Created by 김태형 on 5/30/25.
//

import Foundation

struct ProfileEntity: Equatable, Hashable {
    let nick: String
    let email: String
    let phone: String
    let profileImageURL: String?
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
