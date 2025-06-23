//
//  ChatSendRequest.swift
//  PickMeUp
//
//  Created by 김태형 on 6/1/25.
//

import Foundation

struct ChatSendRequest: Encodable {
    let roomID: String
    let content: String
    let files: [String]?
}
