//
//  StoreListEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import Foundation

struct StoreListEffect {
    func handle(_ intent: StoreListIntent, store: StoreListStore) {
        switch intent {
        case .onAppear:
            Task {
                await fetchStores(store: store)
            }
        default:
            break
        }
    }

    private func fetchStores(store: StoreListStore) async {
        let query = StoreListRequest(category: nil, latitude: nil, longitude: nil, next: nil, limit: 5, orderBy: .distance)
        do {
            let response = try await NetworkManager.shared.fetch(
                StoreRouter.stores(query: query),
                successType: StoreListResponse.self,
                failureType: CommonMessageResponse.self
            )
            if let stores = response.success?.data {
                let entities = stores.map { $0.toStoreListEntity() }
                print("-----결과-----", entities)
                await MainActor.run { store.send(.fetchStores(entities)) }
            } else if let error = response.failure {
                await MainActor.run { store.send(.fetchFailed(error.message)) }
            }
        } catch {
            await MainActor.run { store.send(.fetchFailed(error.localizedDescription)) }
        }
    }
}
