//
//  LastChatEntity.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import Foundation

struct LastChatEntity: Equatable, Hashable {
    let chatID: String
    let roomID: String
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let sender: SenderEntity
    let files: [String]
}
