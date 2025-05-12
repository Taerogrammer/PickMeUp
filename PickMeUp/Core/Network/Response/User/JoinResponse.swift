//
//  JoinResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 5/12/25.
//

import Foundation

struct JoinResponse: Decodable {
    let userId: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String

    // JSON 키와 Swift 프로퍼티 매핑
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case nick
        case accessToken
        case refreshToken
    }
}
