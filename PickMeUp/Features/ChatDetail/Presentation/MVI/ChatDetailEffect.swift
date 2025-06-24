//
//  ChatDetailEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 6/24/25.
//

import Foundation

struct ChatDetailEffect {
    private let messageManager: ChatMessageManager
    private let socketManager: ChatSocketManager

    init(messageManager: ChatMessageManager, socketManager: ChatSocketManager) {
        self.messageManager = messageManager
        self.socketManager = socketManager
    }

    static func handle(
        intent: ChatDetailAction.Intent,
        state: ChatDetailState,
        messageManager: ChatMessageManager,
        socketManager: ChatSocketManager
    ) async -> ChatDetailAction.Result? {
        switch intent {
        case .onAppear:
            return await handleOnAppear(state: state, messageManager: messageManager, socketManager: socketManager)
        case .onDisappear:
            return await handleOnDisappear(socketManager: socketManager)
        case .loadChatHistory:
            return await handleLoadChatHistory(state: state, messageManager: messageManager)
        case .connectSocket:
            return await handleConnectSocket(state: state, socketManager: socketManager)
        case .disconnectSocket:
            return await handleDisconnectSocket(socketManager: socketManager)
        case .sendMessage(let content):
            return await handleSendMessage(content: content, state: state, messageManager: messageManager)
        case .receiveRealtimeMessage(let message):
            return .realtimeMessageReceived(message)
        case .updateNewMessage, .dismissError, .addTempMessage, .removeTempMessage, .clearMessages:
            return nil
        }
    }

    private static func handleOnAppear(
        state: ChatDetailState,
        messageManager: ChatMessageManager,
        socketManager: ChatSocketManager
    ) async -> ChatDetailAction.Result? {
        // 채팅 내역 로드와 소켓 연결을 순차적으로 실행
        await messageManager.loadChatHistory(roomID: state.chatRoom.roomID)

        await MainActor.run {
            socketManager.connect(roomID: state.chatRoom.roomID)
        }

        return nil
    }

    private static func handleOnDisappear(socketManager: ChatSocketManager) async -> ChatDetailAction.Result? {
        await MainActor.run {
            socketManager.disconnect()
        }
        return .socketDisconnected
    }

    private static func handleLoadChatHistory(
        state: ChatDetailState,
        messageManager: ChatMessageManager
    ) async -> ChatDetailAction.Result {
        await messageManager.loadChatHistory(roomID: state.chatRoom.roomID)

        if let error = messageManager.historyError {
            return .loadChatHistoryFailed(error)
        } else {
            return .loadChatHistorySuccess(messageManager.messages)
        }
    }

    private static func handleConnectSocket(
        state: ChatDetailState,
        socketManager: ChatSocketManager
    ) async -> ChatDetailAction.Result? {
        await MainActor.run {
            socketManager.connect(roomID: state.chatRoom.roomID)
        }

        // 소켓 연결 상태 확인 (실제로는 socketManager의 상태를 관찰해야 함)
        return socketManager.isConnected ? .socketConnected : .socketError("연결 실패")
    }

    private static func handleDisconnectSocket(socketManager: ChatSocketManager) async -> ChatDetailAction.Result? {
        await MainActor.run {
            socketManager.disconnect()
        }
        return .socketDisconnected
    }

    private static func handleSendMessage(
        content: String,
        state: ChatDetailState,
        messageManager: ChatMessageManager
    ) async -> ChatDetailAction.Result {
        let success = await messageManager.sendMessage(
            roomID: state.chatRoom.roomID,
            content: content,
            files: nil
        )

        if success {
            // 최신 메시지를 가져와서 반환
            if let lastMessage = messageManager.messages.last {
                return .sendMessageSuccess(lastMessage)
            } else {
                return .sendMessageFailed("메시지 전송 후 확인 실패")
            }
        } else {
            let error = messageManager.sendError ?? "메시지 전송 실패"
            return .sendMessageFailed(error)
        }
    }
}
