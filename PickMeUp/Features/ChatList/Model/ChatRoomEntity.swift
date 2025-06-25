//
//  ChatRoomEntity.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import Foundation

struct ChatRoomEntity: Equatable, Hashable, Identifiable {
    var id: String { roomID }

    let roomID: String
    let createdAt: Date
    let updatedAt: Date
    let participants: [ParticipantEntity]
    let lastChat: LastChatEntity?
}
