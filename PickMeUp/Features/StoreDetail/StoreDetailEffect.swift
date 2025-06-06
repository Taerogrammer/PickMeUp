//
//  StoreDetailEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import SwiftUI

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
                            store.send(.loadMenuImages(items: success.toState().entity.menuItems))
                            store.send(.loadCarouselImages(imageURLs: success.toState().entity.imageCarousel.imageURLs))
                        }
                    } else if let failure = result.failure {
                        print("❌ 서버 오류: \(failure.message)")
                    } else {
                        print("❌ 알 수 없는 오류: 응답이 비어 있음")
                    }
                } catch {
                    print("❌ 네트워크 오류: \(error.localizedDescription)")
                }
            }

        case .tapLike:
            Task {
                await handleLike(store: store)
            }

        case .loadMenuImages(let items):
            for item in items {
                ImageLoader.load(from: item.menuImageURL, responder: MenuImageResponder(menuID: item.menuID, store: store))
            }

        case .loadCarouselImages(let imageURLs):
            for imageURL in imageURLs {
                ImageLoader.load(from: imageURL, responder: CarouselImageResponder(imageURL: imageURL, store: store))
            }

        default:
            break
        }
    }

    private func handleLike(store: StoreDetailStore) async {
        let currentLikeStatus = store.state.entity.imageCarousel.isLiked
        let newLikeStatus = !currentLikeStatus

        // 로딩 상태 시작
        await MainActor.run {
            store.send(.setLikeLoading(isLoading: true))
        }

        let request = StoreLikeRequest(like_status: newLikeStatus)

        do {
            let result = try await NetworkManager.shared.fetch(
                StoreRouter.like(query: StoreIDRequest(id: store.state.storeID),
                                                       request: request),
                successType: StoreLikeResponse.self,
                failureType: CommonMessageResponse.self
            )

            await MainActor.run {
                store.send(.setLikeLoading(isLoading: false))

                // 올바른 필드명 사용: like_status
                if let success = result.success {
                    store.send(.likeSuccess(isLiked: success.like_status))
                } else if let failure = result.failure {
                    store.send(.likeFailed(errorMessage: failure.message))
                }
            }
        } catch {
            await MainActor.run {
                store.send(.setLikeLoading(isLoading: false))
                store.send(.likeFailed(errorMessage: error.localizedDescription))
            }
        }
    }
}

final class MenuImageResponder: ImageLoadRespondable {
    private let menuID: String
    private let store: StoreDetailStore

    init(menuID: String, store: StoreDetailStore) {
        self.menuID = menuID
        self.store = store
    }

    func onImageLoaded(_ image: UIImage) {
        DispatchQueue.main.async {
            self.store.updateMenuImage(for: self.menuID, image: image)
        }
    }

    func onImageLoadFailed(_ errorMessage: String) {
        print("❌ \(menuID) 이미지 로딩 실패: \(errorMessage)")
    }
}

final class CarouselImageResponder: ImageLoadRespondable {
    private let imageURL: String
    private let store: StoreDetailStore

    init(imageURL: String, store: StoreDetailStore) {
        self.imageURL = imageURL
        self.store = store
    }

    func onImageLoaded(_ image: UIImage) {
        DispatchQueue.main.async {
            self.store.send(.loadCarouselImageSuccess(imageURL: self.imageURL, image: image))
        }
    }

    func onImageLoadFailed(_ errorMessage: String) {
        DispatchQueue.main.async {
            self.store.send(.loadCarouselImageFailed(imageURL: self.imageURL, errorMessage: errorMessage))
        }
    }
}
