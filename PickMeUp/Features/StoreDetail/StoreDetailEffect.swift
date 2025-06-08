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
                await handleLikeOptimistic(store: store)
            }

        case .loadMenuImages(let items):
            for item in items {
                ImageLoader.load(from: item.menuImageURL, responder: MenuImageResponder(menuID: item.menuID, store: store))
            }

        case .loadCarouselImages(let imageURLs):
            for imageURL in imageURLs {
                ImageLoader.load(from: imageURL, responder: CarouselImageResponder(imageURL: imageURL, store: store))
            }

        case .addMenuToCart:
            guard let menu = store.state.selectedMenu else { return }

            let cartItem = CartItem(menu: menu, quantity: store.state.tempQuantity)
            print("🛒 장바구니에 추가: \(menu.name) × \(store.state.tempQuantity)")

            store.send(.menuAddedToCart(cartItem))

        default:
            break
        }
    }

    // MARK: - 🚀 Optimistic UI 좋아요 처리
    private func handleLikeOptimistic(store: StoreDetailStore) async {
        let currentLikeStatus = store.state.entity.imageCarousel.isLiked
        let newLikeStatus = !currentLikeStatus

        print("🚀 [Optimistic UI 시작] \(currentLikeStatus) → \(newLikeStatus)")

        await MainActor.run {
            store.send(.likeOptimistic(isLiked: newLikeStatus))
            store.send(.setLikeLoading(isLoading: true))
        }

        let request = StoreLikeRequest(like_status: newLikeStatus)

        do {
            let result = try await NetworkManager.shared.fetch(
                StoreRouter.like(query: StoreIDRequest(id: store.state.storeID), request: request),
                successType: StoreLikeResponse.self,
                failureType: CommonMessageResponse.self
            )

            await MainActor.run {
                store.send(.setLikeLoading(isLoading: false))

                if let success = result.success {
                    if success.like_status != newLikeStatus {
                        print("⚠️ 서버와 로컬 상태 불일치 - 서버 상태로 복구")
                        store.send(.likeSuccess(isLiked: success.like_status))
                    } else {
                        print("✅ 서버와 로컬 상태 일치 - Optimistic UI 성공")
                    }
                } else if let failure = result.failure {
                    print("❌ 좋아요 실패 - 원래 상태로 복구: \(failure.message)")
                    store.send(.likeRollback(isLiked: currentLikeStatus))
                    store.send(.likeFailed(errorMessage: failure.message))
                }
            }
        } catch {
            print("📦 [네트워크 에러 - 롤백]: \(error)")
            await MainActor.run {
                store.send(.setLikeLoading(isLoading: false))
                store.send(.likeRollback(isLiked: currentLikeStatus))
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
