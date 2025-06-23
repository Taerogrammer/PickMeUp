//
//  ChatListState.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import Foundation

struct ChatListState {
    var chatRooms: [ChatModel] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var selectedChatRoom: ChatModel? = nil
    var currentUserID: String? = nil

    var isEmptyState: Bool {
        !isLoading && chatRooms.isEmpty
    }
}
