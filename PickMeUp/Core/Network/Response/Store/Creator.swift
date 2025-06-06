//
//  Creator.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import Foundation

struct Creator: Decodable {
    let userID: String
    let nick: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick
    }
}
