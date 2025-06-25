//
//  CoreDataExtensions.swift
//  PickMeUp
//
//  Created by 김태형 on 6/25/25.
//

import CoreData
import Foundation

// MARK: - Entity to Model Conversion Extensions
extension ChatMessage {
    func toEntity() -> ChatMessageEntity {
        let filesArray: [String]
        if let filesData = files,
           let decodedFiles = try? JSONDecoder().decode([String].self, from: filesData) {
            filesArray = decodedFiles
        } else {
            filesArray = []
        }

        let senderEntity = sender?.toEntity() ?? SenderEntity(userID: "", nick: "Unknown", profileImage: nil)

        return ChatMessageEntity(
            id: id ?? "",
            roomID: roomID ?? "",
            content: content ?? "",
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date(),
            sender: senderEntity,
            files: filesArray
        )
    }
}

extension Sender {
    func toEntity() -> SenderEntity {
        return SenderEntity(
            userID: userID ?? "",
            nick: nick ?? "",
            profileImage: profileImage
        )
    }
}

extension ChatRoom {
    func toEntity() -> ChatRoomEntity {
        let participantEntities = (participants?.allObjects as? [Participant] ?? [])
            .map { $0.toParticipantEntity() }

        let lastChatEntity = lastChat?.toEntity()

        return ChatRoomEntity(
            roomID: roomID ?? "",
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date(),
            participants: participantEntities,
            lastChat: lastChatEntity
        )
    }
}

extension Participant {
    func toParticipantEntity() -> ParticipantEntity {
        return ParticipantEntity(
            userID: userID ?? "",
            nick: nick ?? "",
            profileImage: profileImage
        )
    }
}

extension LastChat {
    func toEntity() -> LastChatEntity {
        let filesArray: [String]
        if let filesData = files,
           let decodedFiles = try? JSONDecoder().decode([String].self, from: filesData) {
            filesArray = decodedFiles
        } else {
            filesArray = []
        }

        let senderEntity = sender?.toEntity() ?? SenderEntity(userID: "", nick: "Unknown", profileImage: nil)

        return LastChatEntity(
            chatID: chatID ?? "",
            roomID: roomID ?? "",
            content: content ?? "",
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date(),
            sender: senderEntity,
            files: filesArray
        )
    }
}

// MARK: - Model to Entity Conversion Extensions
extension ChatMessageEntity {
    func toCoreDataEntity(context: NSManagedObjectContext, sender: Sender, room: ChatRoom) -> ChatMessage {
        let chatMessage = ChatMessage(context: context)
        chatMessage.id = id
        chatMessage.roomID = roomID
        chatMessage.content = content
        chatMessage.createdAt = createdAt
        chatMessage.updatedAt = updatedAt
        chatMessage.sender = sender
        chatMessage.room = room

        // files 배열을 Data로 변환
        if let filesData = try? JSONEncoder().encode(files) {
            chatMessage.files = filesData
        }

        return chatMessage
    }
}

extension SenderEntity {
    func toCoreDataEntity(context: NSManagedObjectContext) -> Sender {
        let sender = Sender(context: context)
        sender.userID = userID
        sender.nick = nick
        sender.profileImage = profileImage
        return sender
    }
}

extension ChatRoomEntity {
    func toCoreDataEntity(context: NSManagedObjectContext) -> ChatRoom {
        let chatRoom = ChatRoom(context: context)
        chatRoom.roomID = roomID
        chatRoom.createdAt = createdAt
        chatRoom.updatedAt = updatedAt
        return chatRoom
    }
}

extension ParticipantEntity {
    func toCoreDataEntity(context: NSManagedObjectContext, room: ChatRoom) -> Participant {
        let participant = Participant(context: context)
        participant.userID = userID
        participant.nick = nick
        participant.profileImage = profileImage
        participant.room = room
        return participant
    }
}

extension LastChatEntity {
    func toCoreDataEntity(context: NSManagedObjectContext, sender: Sender, room: ChatRoom) -> LastChat {
        let lastChat = LastChat(context: context)
        lastChat.chatID = chatID
        lastChat.roomID = roomID
        lastChat.content = content
        lastChat.createdAt = createdAt
        lastChat.updatedAt = updatedAt
        lastChat.sender = sender
        lastChat.room = room

        // files 배열을 Data로 변환
        if let filesData = try? JSONEncoder().encode(files) {
            lastChat.files = filesData
        }

        return lastChat
    }
}
