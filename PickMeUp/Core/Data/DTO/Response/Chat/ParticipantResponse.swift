//
//  ParticipantModelResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import Foundation

struct ParticipantResponse: Decodable {
    let userID: String
    let nick: String
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, profileImage
    }
}

extension ParticipantResponse {
    func toEntity() -> ParticipantEntity {
        ParticipantEntity(
            userID: userID,
            nick: nick,
            profileImage: profileImage
        )
    }
}
