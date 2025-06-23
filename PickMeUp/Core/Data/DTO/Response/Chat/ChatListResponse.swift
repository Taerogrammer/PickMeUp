//
//  ChatListResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 6/1/25.
//

import Foundation

struct ChatListResponse: Decodable {
    let data: [ChatModel]
}

struct ChatModel: Decodable, Identifiable {
    var id: String { roomID }

    let roomID: String
    let createdAt: String
    let updatedAt: String
    let participants: [ParticipantModel]
    let lastChat: LastChatModel?

    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case createdAt, updatedAt, participants, lastChat
    }
}

struct ParticipantModel: Decodable {
    let userID: String
    let nick: String
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, profileImage
    }
}

struct LastChatModel: Decodable {
    let chatID: String
    let roomID: String
    let content: String
    let createdAt: String
    let updatedAt: String
    let sender: SenderModel
    let files: [String]

    enum CodingKeys: String, CodingKey {
        case chatID = "chat_id"
        case roomID = "room_id"
        case content, createdAt, updatedAt, sender, files
    }
}

struct SenderModel: Decodable {
    let userID: String
    let nick: String
    let profileImage: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick, profileImage
    }
}
