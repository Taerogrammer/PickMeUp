//
//  ChatDetailState.swift
//  PickMeUp
//
//  Created by 김태형 on 6/24/25.
//

import Foundation

struct ChatDetailState {
    let chatRoom: ChatRoomEntity
    let currentUserID: String

    var messages: [ChatMessageEntity] = []
    var newMessage: String = ""
    var isLoading: Bool = false
    var isLoadingHistory: Bool = false
    var isSocketConnected: Bool = false

    var sendError: String?
    var historyError: String?
    var errorMessage: String?

    // Computed Properties
    var opponentName: String {
        let opponent = chatRoom.participants.first { $0.userID != currentUserID }
        return opponent?.nick ?? "알 수 없는 사용자"
    }

    var canSendMessage: Bool {
        !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }

    var hasError: Bool {
        sendError != nil || historyError != nil || errorMessage != nil
    }

    var errorText: String {
        if let sendError = sendError {
            return "전송 오류: \(sendError)"
        } else if let historyError = historyError {
            return "채팅 내역 로드 오류: \(historyError)"
        } else if let errorMessage = errorMessage {
            return "오류: \(errorMessage)"
        }
        return ""
    }

    // Helper Methods - 중복 체크 로직 개선
    mutating func addMessage(_ message: ChatMessageEntity) {
        // 중복 체크: ID 또는 (content + timestamp + sender)로 중복 판단
        let isDuplicate = messages.contains { existingMessage in
            existingMessage.id == message.id ||
            (existingMessage.content == message.content &&
             existingMessage.sender.userID == message.sender.userID &&
             abs(existingMessage.createdAt.timeIntervalSince(message.createdAt)) < 2.0) // 2초 이내
        }

        if !isDuplicate {
            messages.append(message)
            messages.sort { $0.createdAt < $1.createdAt }
            print("✅ 메시지 추가됨: \(message.content)")
        } else {
            print("📝 중복 메시지 감지, 추가하지 않음: \(message.content)")
        }
    }

    mutating func removeMessage(withId id: String) {
        messages.removeAll { $0.id == id }
    }
}
