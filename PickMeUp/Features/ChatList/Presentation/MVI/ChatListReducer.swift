//
//  ChatListReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import Foundation

struct ChatListReducer {
    static func reduce(state: inout ChatListState, intent: ChatListAction.Intent) {
        switch intent {
        case .onAppear:
            state.currentUserID = KeychainManager.shared.load(key: KeychainType.userID.rawValue)
        case .loadChatList, .refreshChatList:
            state.isLoading = true
            state.errorMessage = nil
        case .selectChatRoom(let chatRoom):
            state.selectedChatRoom = chatRoom
        case .dismissChatRoom:
            state.selectedChatRoom = nil
        case .dismissError:
            state.errorMessage = nil
        case .startNewChat:
            // TODO: - 새 채팅 시작 로직
            break
        }
    }

    static func reduce(state: inout ChatListState, result: ChatListAction.Result) {
        switch result {
        case .loadChatListSuccess(let chatRooms):
            state.isLoading = false
            state.chatRooms = chatRooms
            state.errorMessage = nil
            print("채팅방 \(chatRooms.count)개 로딩")
        case .loadChatListFailed(let error):
            state.isLoading = false
            state.errorMessage = error
            print("채팅 목록 로드 실패: \(error)")
        }
    }
}
