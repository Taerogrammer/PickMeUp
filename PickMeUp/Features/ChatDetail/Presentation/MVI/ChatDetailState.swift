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

    // Helper Methods
    mutating func addMessage(_ message: ChatMessageEntity) {
        if !messages.contains(where: { $0.id == message.id }) {
            messages.append(message)
            messages.sort { $0.createdAt < $1.createdAt }
        }
    }

    mutating func removeMessage(withId id: String) {
        messages.removeAll { $0.id == id }
    }
}
