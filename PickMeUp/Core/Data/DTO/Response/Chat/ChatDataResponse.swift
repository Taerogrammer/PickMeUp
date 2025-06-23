//
//  ChatModelResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import Foundation

struct ChatDataResponse: Decodable, Identifiable {
    var id: String { roomID }

    let roomID: String
    let createdAt: String
    let updatedAt: String
    let participants: [ParticipantResponse]
    let lastChat: LastChatResponse?

    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case createdAt, updatedAt, participants, lastChat
    }
}

extension ChatDataResponse {
    func toEntity() -> ChatRoomEntity {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let createdDate = formatter.date(from: createdAt) ?? Date()
        let updatedDate = formatter.date(from: updatedAt) ?? Date()

        return ChatRoomEntity(
            roomID: roomID,
            createdAt: createdDate,
            updatedAt: updatedDate,
            participants: participants.map { $0.toEntity() },
            lastChat: lastChat?.toEntity()
        )
    }
}
