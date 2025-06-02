//
//  StoreListView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import SwiftUI

struct StoreListView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
                Task {
                    await fetchStores()
                }
            }
    }

    private func fetchStores() async {
        let query = StoreListRequest(
            category: nil,
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
}

#Preview {
    StoreListView()
}
