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
                let response = StoreDetailResponse.mock()
                await MainActor.run {
                    store.send(.fetchedStoreDetail(response))
                }
            }
        default:
            break
        }
    }
}
