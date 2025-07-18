//
//  ChatListEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import Foundation

struct ChatListEffect {
    static func handle(intent: ChatListAction.Intent, state: ChatListState, router: AppRouter) async -> ChatListAction.Result? {
        switch intent {
        case .onAppear, .loadChatList, .refreshChatList:
            return await handleLoadChatList()
        case .selectChatRoom(let chatRoom):
            if let currentUserID = state.currentUserID {
                await MainActor.run {
                    router.navigate(to: .chatDetail(chatRoom: chatRoom, currentUserID: currentUserID))
                }
            }
            return nil
        case .dismissChatRoom, .dismissError, .startNewChat:
            return nil
        }
    }

    private static func handleLoadChatList() async -> ChatListAction.Result {
        do {
            let response = try await NetworkManager.shared.fetch(
                ChatRouter.getChat,
                successType: ChatListResponse.self,
                failureType: CommonMessageResponse.self
            )

            if let success = response.success {
                print("응답 데이터: \(success.data)")
                print("데이터 개수: \(success.data.count)")

                let entities = success.data.map { $0.toEntity() }
                return .loadChatListSuccess(entities)
            } else if let failure = response.failure {
                return .loadChatListFailed(failure.message)
            } else {
                return .loadChatListFailed("예상치 못한 오류가 발생하였습니다.")
            }
        } catch {
            return .loadChatListFailed("네트워크 오류가 발생했습니다: \(error.localizedDescription)")
        }
    }
}
