//
//  ChatMessageEntity.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import Foundation

struct ChatMessageEntity: Identifiable {
    let id: String
    let roomID: String
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let sender: SenderEntity
    let files: [String]

    var isFromCurrentUser: Bool {
        return false // 임시값, 나중에 currentUserID와 비교
    }
}
