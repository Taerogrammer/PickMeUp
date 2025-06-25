//
//  ChatRepositoryProtocol.swift
//  PickMeUp
//
//  Created by 김태형 on 6/25/25.
//

import Foundation

protocol ChatRepositoryProtocol: AnyObject {
    // 채팅 메시지
    func fetchMessages(roomID: String) async -> Result<[ChatMessageEntity], CoreDataError>
    func saveMessage(_ message: ChatMessageEntity, in roomID: String) async -> Result<ChatMessageEntity, CoreDataError>
    func deleteMessage(id: String) async -> Result<Void, CoreDataError>

    // 채팅방
    func fetchChatRooms() async -> Result<[ChatRoomEntity], CoreDataError>
    func saveChatRoom(_ chatRoom: ChatRoomEntity) async -> Result<ChatRoomEntity, CoreDataError>
    func deleteChatRoom(roomID: String) async -> Result<Void, CoreDataError>

    // 사용자
    func fetchOrCreateSender(userID: String, nick: String, profileImage: String?) async -> Result<Sender, CoreDataError>

    // 동기화
    func clearAllData() async -> Result<Void, CoreDataError>
}
