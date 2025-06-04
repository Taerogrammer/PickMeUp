//
//  StoreScreen.swift
//  PickMeUp
//
//  Created by 김태형 on 6/1/25.
//

import SwiftUI

struct StoreScreen: View {
    let store: StoreListStore
    var body: some View {
        VStack(spacing: 0) {
            StoreSearchHeaderView()
            StoreListView(store: store)
        }
        .background(Color.gray30)
    }

    private func fetchChatList() async {
        do {
            let response = try await NetworkManager.shared.fetch(
                ChatRouter.getChat,
                successType: ChatListResponse.self,
                failureType: CommonMessageResponse.self
            )

            if let chats = response.success?.data {
                print("✅ Fetched Chats:", chats.map { $0.roomID }) // 예시로 roomID 출력
            } else if let error = response.failure {
                print("❌ Chat list fetch 실패: \(error.message)")
            }
        } catch {
            print("❌ Chat list fetch 예외 발생:", error.localizedDescription)
        }
    }
}

#Preview {
    StoreScreen(store: .preview)
}
