//
//  SenderResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import Foundation

struct SenderResponse: Decodable {
    let userID: String
    let nick: String
    let profileImage: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, profileImage
    }
}

extension SenderResponse {
    func toEntity() -> SenderEntity {
        SenderEntity(
            userID: userID,
            nick: nick,
            profileImage: profileImage
        )
    }
}
