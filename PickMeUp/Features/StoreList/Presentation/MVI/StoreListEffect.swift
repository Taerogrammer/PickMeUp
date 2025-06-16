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
                Task {
                    await loadImagesParallel(storeID: storeID, imagePaths: imagePaths, store: store)
                }
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
            } else if let error = response.failure {
                store.send(.fetchFailed(error.message))
            }
        } catch {
            store.send(.fetchFailed(error.localizedDescription))
        }
    }

    @MainActor
    private func loadNextPage(store: StoreListStore) async {
        guard let nextCursor = store.state.nextCursor else {
            store.send(.loadMoreFailed("nextCursor가 없습니다"))
            return
        }

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
            } else if let error = response.failure {
                store.send(.loadMoreFailed(error.message))
            }
        } catch {
            store.send(.loadMoreFailed(error.localizedDescription))
        }
    }

    // MARK: - 병렬 이미지 로딩
    private func loadImagesParallel(storeID: String, imagePaths: [String], store: StoreListStore) async {
        let maxImages = min(imagePaths.count, 3)
        let pathsToLoad = Array(imagePaths.prefix(maxImages))

        // TaskGroup을 사용하여 이미지 병렬화
        let images = await withTaskGroup(of: (Int, UIImage?).self, returning: [UIImage?].self) { group in
            var results: [UIImage?] = Array(repeating: nil, count: maxImages)

            // 각 이미지를 병렬로 코딩
            for (index, path) in pathsToLoad.enumerated() {
                group.addTask {
                    let image = await loadSingleImage(from: path)
                    return (index, image)
                }
            }

            for await (index, image) in group {
                if index < results.count {
                    results[index] = image
                }
            }

            return results
        }

        await MainActor.run {
            store.send(.loadImageSuccess(storeID: storeID, images: images))
        }
    }

    // MARK: - 단일 이미지 비동기 처리
    private func loadSingleImage(from path: String, accessTokenKey: String = TokenType.accessToken.rawValue) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let responder = SingleImageResponder { result in
                continuation.resume(returning: result)
            }
            ImageLoader.load(from: path, accessTokenKey: accessTokenKey, responder: responder)
        }
    }
}

final class SingleImageResponder: ImageLoadRespondable {
    private let completion: (UIImage?) -> Void

    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }

    func onImageLoaded(_ image: UIImage) {
        completion(image)
    }

    func onImageLoadFailed(_ errorMessage: String) {
        print("이미지 로딩 실패: \(errorMessage)")
        completion(nil)
    }
}
