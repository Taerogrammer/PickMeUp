//
//  ChatListAction.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import Foundation

enum ChatListAction {
    enum Intent {
        case onAppear
        case loadChatList
        case refreshChatList
        case selectChatRoom(ChatModel)
        case dismissChatRoom
        case dismissError
        case startNewChat
    }

    enum Result {
        case loadChatListSuccess([ChatModel])
        case loadChatListFailed(String)
    }
}
