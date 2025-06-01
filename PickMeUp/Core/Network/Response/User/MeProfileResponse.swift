//
//  MeProfileResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 5/28/25.
//

import Foundation

struct MeProfileResponse: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let profileImage: String?
    let phoneNum: String
}

extension MeProfileResponse {
    func toEntity() -> ProfileEntity {
        return ProfileEntity(
            nick: self.nick,
            email: self.email,
            phone: self.phoneNum,
            profileImageURL: self.profileImage)
    }
}

extension MeProfileResponse {
    static let mock = MeProfileResponse(
        user_id: "65c9aa6932b0964405117d97",
        email: "sesac@sesac.com",
        nick: "김새싹",
        profileImage: "/data/profiles/1748751154046.jpg",
        phoneNum: "01012341234"
    )
}

extension MeProfileResponse {
    static let empty = MeProfileResponse(
        user_id: "",
        email: "",
        nick: "",
        profileImage: "",
        phoneNum: ""
    )
}
