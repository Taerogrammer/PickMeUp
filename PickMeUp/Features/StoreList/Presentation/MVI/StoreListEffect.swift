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
//            CachingStrategyTest.testAllStrategies()

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

            // 캐시 상태 확인
            if response.isFromCache {
                print("캐시된 데이터: 304")
            } else {
                print("새로운 데이터: 200")
            }

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

    // WWDC 공식 다운샘플링을 적용한 병렬 이미지 로딩
    private func loadImagesParallel(storeID: String, imagePaths: [String], store: StoreListStore) async {
        let maxImages = min(imagePaths.count, 3)
        let pathsToLoad = Array(imagePaths.prefix(maxImages))

        // WWDC에서 권장하는 실제 표시 크기에 맞춘 이미지 크기들
        let imageSizes = [
            CGSize(width: 260, height: 120),
            CGSize(width: 92, height: 62),
            CGSize(width: 92, height: 62)
        ]

        // TaskGroup을 사용한 병렬 처리 (Swift Concurrency + WWDC 다운샘플링)
        let images = await withTaskGroup(of: (Int, UIImage?).self, returning: [UIImage?].self) { group in
            var results: [UIImage?] = Array(repeating: nil, count: maxImages)

            // 각 이미지를 병렬로 다운샘플링 처리
            for (index, path) in pathsToLoad.enumerated() {
                group.addTask {
                    let targetSize = index < imageSizes.count ? imageSizes[index] : CGSize(width: 92, height: 62)
                    let image = await loadSingleImageWithWWDCDownsampling(
                        from: path,
                        targetSize: targetSize,
                        scale: UIScreen.main.scale
                    )
                    return (index, image)
                }
            }

            // 완료된 순서대로 결과 수집 후 원래 순서로 정렬
            for await (index, image) in group {
                if index < results.count {
                    results[index] = image
                }
            }

            return results
        }

        // 메인 스레드에서 UI 업데이트
        await MainActor.run {
            store.send(.loadImageSuccess(storeID: storeID, images: images))
        }
    }

    // WWDC 공식 방식으로 단일 이미지 로딩 (withCheckedContinuation 사용)
    private func loadSingleImageWithWWDCDownsampling(
        from path: String,
        targetSize: CGSize,
        scale: CGFloat,
        accessTokenKey: String = TokenType.accessToken.rawValue
    ) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let responder = SingleImageResponder { image in
                continuation.resume(returning: image)
            }

            // WWDC 공식 다운샘플링이 적용된 ImageLoader 사용
            ImageLoader.load(
                from: path,
                targetSize: targetSize,      // 정확한 UI 크기로 다운샘플링
                scale: scale,                // 레티나 디스플레이 대응
                accessTokenKey: accessTokenKey,
                responder: responder
            )
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
