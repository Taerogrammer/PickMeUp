//
//  StoreScreen.swift
//  PickMeUp
//
//  Created by 김태형 on 6/1/25.
//

import SwiftUI

struct StoreScreen: View {
    var body: some View {
        Text("Store List")
            .onAppear {
                Task {
                    await fetchChatList()
                }
            }
    }

    private func fetchStores() async {
        let query = StoreListRequest(
            category: "패스트푸드",
            latitude: nil,
            longitude: nil,
            next: nil,
            limit: 5,
            orderBy: .distance
        )
        do {
            let response = try await NetworkManager.shared.fetch(
                StoreRouter.stores(query: query),
                successType: StoreListResponse.self,
                failureType: CommonMessageResponse.self
            )

            if let stores = response.success?.data {
                print("✅ Fetched Stores:", stores.map { $0.name }) // 이름만 출력
            } else if let error = response.failure {
                print("❌ Store fetch 실패: \(error.message)")
            }
        } catch {
            print("❌ Store fetch 예외 발생:", error.localizedDescription)
        }
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
    StoreScreen()
}
