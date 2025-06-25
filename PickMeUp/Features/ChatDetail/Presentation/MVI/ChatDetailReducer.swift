//
//  ChatDetailReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 6/24/25.
//

import Foundation

struct ChatDetailReducer {
    static func reduce(state: inout ChatDetailState, intent: ChatDetailAction.Intent) {
        switch intent {
        case .onAppear:
            state.isLoading = true
            state.errorMessage = nil
        case .onDisappear:
            state.isSocketConnected = false
        case .loadChatHistory:
            state.isLoadingHistory = true
            state.historyError = nil
        case .connectSocket:
            break // Effect에서 처리
        case .disconnectSocket:
            state.isSocketConnected = false
        case .sendMessage:
            state.isLoading = true
            state.sendError = nil
        case .updateNewMessage(let message):
            state.newMessage = message
        case .dismissError:
            state.sendError = nil
            state.historyError = nil
            state.errorMessage = nil
        case .addTempMessage(let message):
            state.addMessage(message)
        case .removeTempMessage(let messageId):
            state.removeMessage(withId: messageId)
        case .clearMessages:
            state.messages.removeAll()
        case .receiveRealtimeMessage:
            break
        }
    }

    static func reduce(state: inout ChatDetailState, result: ChatDetailAction.Result) {
        switch result {
        case .loadChatHistorySuccess(let messages):
            state.isLoading = false
            state.isLoadingHistory = false
            state.messages = messages.sorted { $0.createdAt < $1.createdAt }
            state.historyError = nil
        case .loadChatHistoryFailed(let error):
            state.isLoading = false
            state.isLoadingHistory = false
            state.historyError = error
        case .sendMessageSuccess(let message):
            state.isLoading = false
            state.newMessage = ""
            state.addMessage(message)
            state.sendError = nil
        case .sendMessageFailed(let error):
            state.isLoading = false
            state.sendError = error
        case .socketConnected:
            state.isSocketConnected = true
            state.errorMessage = nil
        case .socketDisconnected:
            state.isSocketConnected = false
        case .socketError(let error):
            state.isSocketConnected = false
            state.errorMessage = error
        case .newMessageReceived(let message):
            state.addMessage(message)
        case .realtimeMessageReceived(let message): // 새로 추가
            // 실시간으로 받은 메시지를 State에 반영
            state.addMessage(message)
        }
    }
}
