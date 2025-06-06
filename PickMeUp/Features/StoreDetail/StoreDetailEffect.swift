//
//  StoreDetailEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import Foundation

struct StoreDetailEffect {
    func handle(_ action: StoreDetailAction.Intent, store: StoreDetailStore) {
        switch action {
        case .onAppear:
            Task {
                do {
                    let result = try await NetworkManager.shared.fetch(
                        StoreRouter.detail(query: StoreIDRequest(id: store.state.storeID)),
                        successType: StoreDetailResponse.self,
                        failureType: CommonMessageResponse.self
                    )

                    if let success = result.success {
                        await MainActor.run {
                            store.send(.fetchedStoreDetail(success))
                        }
                    } else if let failure = result.failure {
                        print("❌ 서버 오류: \(failure.message)")
                        // 에러 상태를 StoreDetailState로 확장할 수도 있음
                    } else {
                        print("❌ 알 수 없는 오류: 응답이 비어 있음")
                    }
                } catch {
                    print("❌ 네트워크 오류: \(error.localizedDescription)")
                }
            }
        default:
            break
        }
    }
}
