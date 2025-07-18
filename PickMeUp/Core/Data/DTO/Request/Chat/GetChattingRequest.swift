//
//  GetChatRequest.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import Foundation

struct GetChattingRequest: Encodable {
    let roomID: String
    let next: String

    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case next
    }
}
