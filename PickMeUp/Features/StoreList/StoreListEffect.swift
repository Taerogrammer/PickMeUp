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
                Task { @MainActor in
                    store.send(.loadImage(storeID: storeID, imagePaths: imagePaths))
                }
            }

        case .loadImage(let storeID, let imagePaths):
            let responder = StoreListImageResponder(storeID: storeID, store: store, expectedCount: min(imagePaths.count, 3))
            for path in imagePaths.prefix(3) {
                ImageLoader.load(from: path, responder: responder)
            }

        case .loadNextPage:
            Task { await loadNextPage(store: store) }

        case .tapStore(let storeID):
            Task { @MainActor in
                store.router.navigate(to: .storeDetail(storeID: storeID))
            }

        default:
            break
        }
    }

    @MainActor
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
                store.send(.fetchStoresWithCursor(entities, nextCursor: storeResponse.nextCursor))
                print("🔄 API 응답에서 받은 nextCursor: \(storeResponse.nextCursor ?? "nil")")
            } else if let error = response.failure {
                store.send(.fetchFailed(error.message))
            }
        } catch {
            store.send(.fetchFailed(error.localizedDescription))
        }
    }

    @MainActor
    private func loadNextPage(store: StoreListStore) async {
        // 🔑 Reducer에서 이미 조건을 체크했으므로, Effect에서는 nextCursor만 확인
        guard let nextCursor = store.state.nextCursor else {
            print("❌ nextCursor가 없음")
            store.send(.loadMoreFailed("nextCursor가 없습니다"))
            return
        }

        print("🚀 다음 페이지 로드 시작 - cursor: \(nextCursor)")

        let query = StoreListRequest(
            category: nil,
            latitude: nil,
            longitude: nil,
            next: nextCursor,
            limit: 5,
            orderBy: .distance
        )

        do {
            let response = try await NetworkManager.shared.fetch(
                StoreRouter.stores(query: query),
                successType: StoreListResponse.self,
                failureType: CommonMessageResponse.self
            )

            if let storeResponse = response.success {
                let entities = storeResponse.data.map { $0.toStoreListEntity() }
                store.send(.loadMoreSuccess(entities, nextCursor: storeResponse.nextCursor))
                print("✅ 다음 페이지 로드 성공 - \(entities.count)개 추가")
                print("🔄 새로운 nextCursor: \(storeResponse.nextCursor ?? "nil")")
            } else if let error = response.failure {
                store.send(.loadMoreFailed(error.message))
                print("❌ 다음 페이지 로드 실패: \(error.message)")
            }
        } catch {
            store.send(.loadMoreFailed(error.localizedDescription))
            print("❌ 다음 페이지 로드 에러: \(error.localizedDescription)")
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
            Task { @MainActor in
                store.send(.loadImageSuccess(storeID: storeID, images: images))
            }
        }
    }
}
