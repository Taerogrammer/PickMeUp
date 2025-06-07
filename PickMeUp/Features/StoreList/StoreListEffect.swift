//
//  StoreListEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import SwiftUI

struct StoreListEffect {
    func handle(_ intent: StoreListAction.Intent, store: StoreListStore) {
        switch intent {
        case .onAppear:
            Task { await fetchStores(store: store) }

        case .storeItemOnAppear(let storeID, let imagePaths):
            if store.state.loadedImages[storeID] == nil {
                store.send(.loadImage(storeID: storeID, imagePaths: imagePaths))
            }

        case .loadImage(let storeID, let imagePaths):
            let responder = StoreListImageResponder(storeID: storeID, store: store, expectedCount: min(imagePaths.count, 3))
            for path in imagePaths.prefix(3) {
                ImageLoader.load(from: path, responder: responder)
            }

        default: break
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
            if let storeResponse = response.success {
                let entities = storeResponse.data.map { $0.toStoreListEntity() }
                await MainActor.run {
                    // 🔑 MVI 패턴: Reducer를 통해 nextCursor 저장
                    store.send(.fetchStoresWithCursor(entities, nextCursor: storeResponse.nextCursor))
                    print("🔄 API 응답에서 받은 nextCursor: \(storeResponse.nextCursor ?? "nil")")
                }
            } else if let error = response.failure {
                await MainActor.run { store.send(.fetchFailed(error.message)) }
            }
        } catch {
            await MainActor.run { store.send(.fetchFailed(error.localizedDescription)) }
        }
    }
}


final class StoreListImageResponder: ImageLoadRespondable {
    private let storeID: String
    private let store: StoreListStore
    private var index: Int = 0
    private var images: [UIImage?]
    private let expectedCount: Int

    init(storeID: String, store: StoreListStore, expectedCount: Int) {
        self.storeID = storeID
        self.store = store
        self.expectedCount = expectedCount
        self.images = Array(repeating: nil, count: expectedCount)
    }

    func onImageLoaded(_ image: UIImage) {
        if index < expectedCount {
            images[index] = image
            index += 1
        }
        checkAndSend()
    }

    func onImageLoadFailed(_ errorMessage: String) {
        if index < expectedCount {
            images[index] = nil
            index += 1
        }
        checkAndSend()
    }

    private func checkAndSend() {
        if index == expectedCount {
            store.send(.loadImageSuccess(storeID: storeID, images: images))
        }
    }
}
