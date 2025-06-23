//
//  LastChatResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import Foundation

struct LastChatResponse: Decodable {
    let chatID: String
    let roomID: String
    let content: String
    let createdAt: String
    let updatedAt: String
    let sender: SenderResponse
    let files: [String]

    enum CodingKeys: String, CodingKey {
        case chatID = "chat_id"
        case roomID = "room_id"
        case content, createdAt, updatedAt, sender, files
    }
}

extension LastChatResponse {
    func toEntity() -> LastChatEntity {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let createdDate = formatter.date(from: createdAt) ?? Date()
        let updatedDate = formatter.date(from: updatedAt) ?? Date()

        return LastChatEntity(
            chatID: chatID,
            roomID: roomID,
            content: content,
            createdAt: createdDate,
            updatedAt: updatedDate,
            sender: sender.toEntity(),
            files: files
        )
    }
}

enum ConversionError: Error, LocalizedError {
    case invalidDateFormat

    var errorDescription: String? {
        switch self {
        case .invalidDateFormat:
            return "날짜 형식을 변환할 수 없습니다."
        }
    }
}
