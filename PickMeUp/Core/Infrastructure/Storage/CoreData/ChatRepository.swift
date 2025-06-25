//
//  ChatRepository.swift
//  PickMeUp
//
//  Created by 김태형 on 6/25/25.
//

import CoreData
import Foundation

final class ChatRepository: ChatRepositoryProtocol {
    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - 채팅 메시지 조회
    func fetchMessages(roomID: String) async -> Result<[ChatMessageEntity], CoreDataError> {
        return await withCheckedContinuation { continuation in
            let context = coreDataStack.newBackgroundContext()

            context.perform {
                do {
                    let request: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()
                    request.predicate = NSPredicate(format: "roomID == %@", roomID)
                    request.sortDescriptors = [NSSortDescriptor(keyPath: \ChatMessage.createdAt, ascending: true)]

                    let coreDataMessages = try context.fetch(request)
                    let messageEntities = coreDataMessages.map { $0.toEntity() }

                    continuation.resume(returning: .success(messageEntities))
                } catch {
                    continuation.resume(returning: .failure(.fetchError(error)))
                }
            }
        }
    }

    // MARK: - 채팅 메시지 저장
    func saveMessage(_ message: ChatMessageEntity, in roomID: String) async -> Result<ChatMessageEntity, CoreDataError> {
        return await withCheckedContinuation { continuation in
            let context = coreDataStack.newBackgroundContext()

            context.perform {
                do {
                    // 중복 체크
                    let existingRequest: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()
                    existingRequest.predicate = NSPredicate(format: "id == %@", message.id)

                    if let existingMessage = try context.fetch(existingRequest).first {
                        // 이미 존재하는 메시지
                        let entity = existingMessage.toEntity()
                        continuation.resume(returning: .success(entity))
                        return
                    }

                    // Sender 찾기 또는 생성
                    let sender = try self.findOrCreateSender(
                        userID: message.sender.userID,
                        nick: message.sender.nick,
                        profileImage: message.sender.profileImage,
                        in: context
                    )

                    // ChatRoom 찾기 또는 생성
                    let room = try self.findOrCreateChatRoom(roomID: roomID, in: context)

                    // ChatMessage 생성
                    let chatMessage = message.toCoreDataEntity(context: context, sender: sender, room: room)

                    try context.save()

                    let savedEntity = chatMessage.toEntity()
                    continuation.resume(returning: .success(savedEntity))

                } catch {
                    continuation.resume(returning: .failure(.saveError(error)))
                }
            }
        }
    }

    // MARK: - 채팅 메시지 삭제
    func deleteMessage(id: String) async -> Result<Void, CoreDataError> {
        return await withCheckedContinuation { continuation in
            let context = coreDataStack.newBackgroundContext()

            context.perform {
                do {
                    let request: NSFetchRequest<ChatMessage> = ChatMessage.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", id)

                    guard let message = try context.fetch(request).first else {
                        continuation.resume(returning: .failure(.entityNotFound))
                        return
                    }

                    context.delete(message)
                    try context.save()

                    continuation.resume(returning: .success(()))
                } catch {
                    continuation.resume(returning: .failure(.deleteError(error)))
                }
            }
        }
    }

    // MARK: - 채팅방 조회
    func fetchChatRooms() async -> Result<[ChatRoomEntity], CoreDataError> {
        return await withCheckedContinuation { continuation in
            let context = coreDataStack.newBackgroundContext()

            context.perform {
                do {
                    let request: NSFetchRequest<ChatRoom> = ChatRoom.fetchRequest()
                    request.sortDescriptors = [NSSortDescriptor(keyPath: \ChatRoom.updatedAt, ascending: false)]

                    let coreDataRooms = try context.fetch(request)
                    let roomEntities = coreDataRooms.map { $0.toEntity() }

                    continuation.resume(returning: .success(roomEntities))
                } catch {
                    continuation.resume(returning: .failure(.fetchError(error)))
                }
            }
        }
    }

    // MARK: - 채팅방 저장
    func saveChatRoom(_ chatRoom: ChatRoomEntity) async -> Result<ChatRoomEntity, CoreDataError> {
        return await withCheckedContinuation { continuation in
            let context = coreDataStack.newBackgroundContext()

            context.perform {
                do {
                    // 중복 체크
                    let existingRequest: NSFetchRequest<ChatRoom> = ChatRoom.fetchRequest()
                    existingRequest.predicate = NSPredicate(format: "roomID == %@", chatRoom.roomID)

                    let room: ChatRoom
                    if let existingRoom = try context.fetch(existingRequest).first {
                        room = existingRoom
                        // 기존 방 정보 업데이트
                        room.updatedAt = chatRoom.updatedAt
                    } else {
                        // 새 방 생성
                        room = chatRoom.toCoreDataEntity(context: context)

                        // Participants 추가
                        for participantEntity in chatRoom.participants {
                            let participant = participantEntity.toCoreDataEntity(context: context, room: room)
                            room.addToParticipants(participant)
                        }
                    }

                    // LastChat 처리
                    if let lastChatEntity = chatRoom.lastChat {
                        let sender = try self.findOrCreateSender(
                            userID: lastChatEntity.sender.userID,
                            nick: lastChatEntity.sender.nick,
                            profileImage: lastChatEntity.sender.profileImage,
                            in: context
                        )

                        let lastChat = lastChatEntity.toCoreDataEntity(context: context, sender: sender, room: room)
                        room.lastChat = lastChat
                    }

                    try context.save()

                    let savedEntity = room.toEntity()
                    continuation.resume(returning: .success(savedEntity))

                } catch {
                    continuation.resume(returning: .failure(.saveError(error)))
                }
            }
        }
    }

    // MARK: - 채팅방 삭제
    func deleteChatRoom(roomID: String) async -> Result<Void, CoreDataError> {
        return await withCheckedContinuation { continuation in
            let context = coreDataStack.newBackgroundContext()

            context.perform {
                do {
                    let request: NSFetchRequest<ChatRoom> = ChatRoom.fetchRequest()
                    request.predicate = NSPredicate(format: "roomID == %@", roomID)

                    guard let room = try context.fetch(request).first else {
                        continuation.resume(returning: .failure(.entityNotFound))
                        return
                    }

                    context.delete(room) // Cascade로 설정했으므로 관련 데이터도 함께 삭제
                    try context.save()

                    continuation.resume(returning: .success(()))
                } catch {
                    continuation.resume(returning: .failure(.deleteError(error)))
                }
            }
        }
    }

    // MARK: - 사용자 찾기/생성
    func fetchOrCreateSender(userID: String, nick: String, profileImage: String?) async -> Result<Sender, CoreDataError> {
        return await withCheckedContinuation { continuation in
            let context = coreDataStack.newBackgroundContext()

            context.perform {
                do {
                    let sender = try self.findOrCreateSender(
                        userID: userID,
                        nick: nick,
                        profileImage: profileImage,
                        in: context
                    )

                    try context.save()
                    continuation.resume(returning: .success(sender))
                } catch {
                    continuation.resume(returning: .failure(.saveError(error)))
                }
            }
        }
    }

    // MARK: - 모든 데이터 삭제
    func clearAllData() async -> Result<Void, CoreDataError> {
        return await withCheckedContinuation { continuation in
            let context = coreDataStack.newBackgroundContext()

            context.perform {
                do {
                    // 모든 엔티티 삭제 (순서 중요: 관계가 있는 것부터)
                    let entities = ["ChatMessage", "LastChat", "Participant", "ChatRoom", "Sender"]

                    for entityName in entities {
                        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                        try context.execute(deleteRequest)
                    }

                    try context.save()
                    continuation.resume(returning: .success(()))
                } catch {
                    continuation.resume(returning: .failure(.deleteError(error)))
                }
            }
        }
    }
}

// MARK: - Helper Methods
private extension ChatRepository {
    func findOrCreateSender(userID: String, nick: String, profileImage: String?, in context: NSManagedObjectContext) throws -> Sender {
        let request: NSFetchRequest<Sender> = Sender.fetchRequest()
        request.predicate = NSPredicate(format: "userID == %@", userID)

        if let existingSender = try context.fetch(request).first {
            // 기존 사용자 정보 업데이트
            existingSender.nick = nick
            existingSender.profileImage = profileImage
            return existingSender
        } else {
            // 새 사용자 생성
            let senderEntity = SenderEntity(userID: userID, nick: nick, profileImage: profileImage)
            return senderEntity.toCoreDataEntity(context: context)
        }
    }

    func findOrCreateChatRoom(roomID: String, in context: NSManagedObjectContext) throws -> ChatRoom {
        let request: NSFetchRequest<ChatRoom> = ChatRoom.fetchRequest()
        request.predicate = NSPredicate(format: "roomID == %@", roomID)

        if let existingRoom = try context.fetch(request).first {
            return existingRoom
        } else {
            // 임시 채팅방 생성 (나중에 실제 데이터로 업데이트됨)
            let roomEntity = ChatRoomEntity(
                roomID: roomID,
                createdAt: Date(),
                updatedAt: Date(),
                participants: [],
                lastChat: nil
            )
            return roomEntity.toCoreDataEntity(context: context)
        }
    }
}
