//
//  ChatListStore.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import Foundation

final class ChatListStore: ObservableObject {
    @Published private(set) var state: ChatListState

    init(state: ChatListState) {
        self.state = state
    }

    @MainActor
    func send(_ intent: ChatListAction.Intent) {
        ChatListReducer.reduce(state: &state, intent: intent)

        Task {
            if let result = await ChatListEffect.handle(intent: intent, state: state) {
                handleResult(result)
            }
        }
    }

    @MainActor
    private func handleResult(_ result: ChatListAction.Result) {
        ChatListReducer.reduce(state: &state, result: result)
    }
}
