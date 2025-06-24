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

        // 백그라운드에서 채팅 히스토리 로드와 소켓 연결을 병렬로 처리
        await withTaskGroup(of: Void.self) { group in
            // 1. 채팅 히스토리 로드 (백그라운드)
            group.addTask {
                await messageManager.loadChatHistory(roomID: state.chatRoom.roomID)
            }

            // 2. 소켓 연결 (메인 스레드에서 처리)
            group.addTask {
                await MainActor.run {
                    socketManager.connect(roomID: state.chatRoom.roomID)
                }
            }
        }

        return nil
    }

    // MARK: - 채팅 히스토리 로딩
    private static func handleLoadChatHistory(
        state: ChatDetailState,
        messageManager: ChatMessageManager
    ) async -> ChatDetailAction.Result {

        // 백그라운드에서 채팅 히스토리 로드
        await messageManager.loadChatHistory(roomID: state.chatRoom.roomID)

        // 메인 스레드에서 결과 확인 및 반환
        return await MainActor.run {
            if let error = messageManager.historyError {
                return .loadChatHistoryFailed(error)
            } else {
                let messages = messageManager.messages
                return .loadChatHistorySuccess(messages)
            }
        }
    }

    // MARK: - 소켓 연결
    private static func handleConnectSocket(
        state: ChatDetailState,
        socketManager: ChatSocketManager
    ) async -> ChatDetailAction.Result? {

        await MainActor.run {
            socketManager.connect(roomID: state.chatRoom.roomID)
        }

        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초

        return await MainActor.run {
            return socketManager.isConnected ? .socketConnected : .socketError("연결 실패")
        }
    }

    // MARK: - 메시지 전송
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

        return await MainActor.run {
            if success {
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

    private static func handleOnDisappear(socketManager: ChatSocketManager) async -> ChatDetailAction.Result? {
        await MainActor.run {
            socketManager.disconnect()
        }
        return .socketDisconnected
    }

    private static func handleDisconnectSocket(socketManager: ChatSocketManager) async -> ChatDetailAction.Result? {
        await MainActor.run {
            socketManager.disconnect()
        }
        return .socketDisconnected
    }
}
