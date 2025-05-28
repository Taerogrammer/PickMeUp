//
//  MeProfileResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 5/28/25.
//

import Foundation

struct MeProfileResponse: Encodable {
    let user_id: String
    let email: String
    let nick: String
    let profileImage: String
    let phoneNum: String
}

extension MeProfileResponse {
    static let mock = MeProfileResponse(
        user_id: "65c9aa6932b0964405117d97",
        email: "sesac@sesac.com",
        nick: "김새싹",
        profileImage: "/data/profiles/1707716853682.png",
        phoneNum: "01012341234"
    )
}
