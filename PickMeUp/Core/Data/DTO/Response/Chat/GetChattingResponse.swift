//
//  GetChattingResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import Foundation

struct GetChattingResponse: Decodable {
    let data: [ChatHistoryResponse]
}

struct ChatHistoryResponse: Decodable {
    let chatID: String
    let roomID: String
    let content: String
    let createdAt: String
    let updatedAt: String
    let sender: SenderResponse
    let files: [String]?

    enum CodingKeys: String, CodingKey {
        case chatID = "chat_id"
        case roomID = "room_id"
        case content, createdAt, updatedAt, sender, files
    }
}

extension ChatHistoryResponse {
    func toEntity() -> ChatMessageEntity {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let createdDate = formatter.date(from: createdAt) ?? Date()
        let updatedDate = formatter.date(from: updatedAt) ?? Date()

        return ChatMessageEntity(
            id: chatID,
            roomID: roomID,
            content: content,
            createdAt: createdDate,
            updatedAt: updatedDate,
            sender: sender.toEntity(),
            files: files ?? []
        )
    }
}
