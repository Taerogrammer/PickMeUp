//
//  ChatDetailAction.swift
//  PickMeUp
//
//  Created by 김태형 on 6/24/25.
//

import Foundation

enum ChatDetailAction {
    enum Intent {
        case onAppear
        case onDisappear
        case loadChatHistory
        case connectSocket
        case disconnectSocket
        case sendMessage(String)
        case updateNewMessage(String)
        case dismissError
        case addTempMessage(ChatMessageEntity)
        case removeTempMessage(String)
        case clearMessages
        case receiveRealtimeMessage(ChatMessageEntity)
    }

    enum Result {
        case loadChatHistorySuccess([ChatMessageEntity])
        case loadChatHistoryFailed(String)
        case sendMessageSuccess(ChatMessageEntity)
        case sendMessageFailed(String)
        case socketConnected
        case socketDisconnected
        case socketError(String)
        case newMessageReceived(ChatMessageEntity)
        case realtimeMessageReceived(ChatMessageEntity)
    }
}
