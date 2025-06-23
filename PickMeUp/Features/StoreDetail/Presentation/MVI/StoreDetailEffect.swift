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
                await fetchStoreDetail(store: store)
            }

        case .tapLike:
            Task {
                await handleLikeOptimistic(store: store)
            }

        case .loadMenuImages(let items):
            for item in items {
                ImageLoader.load(from: item.menuImageURL, targetSize: CGSize(width: 160, height: 120), responder: MenuImageResponder(menuID: item.menuID, store: store))
            }

        case .loadCarouselImages(let imageURLs):
            print("⚡ [Effect] loadCarouselImages 처리 - \(imageURLs.count)개 이미지")
            for imageURL in imageURLs {
                ImageLoader.load(from: imageURL, targetSize: CGSize(width: 750, height: 500), responder: CarouselImageResponder(imageURL: imageURL, store: store))
            }

        case .addMenuToCart:
            Task { @MainActor in
                guard let menu = store.state.selectedMenu else {
                    return
                }
                let cartItem = CartItem(menu: menu, quantity: store.state.tempQuantity)
                store.send(.menuAddedToCart(cartItem))
            }

        case .tapPay:
            Task {
                await handleOrderSubmission(store: store)
            }

        case .tapBack:
            Task { @MainActor in
                store.router.pop()
            }

        case .navigateToPayment(let paymentInfo):
            Task { @MainActor in
                store.router.navigate(to: .payment(paymentInfo))
            }

        default:
            break
        }
    }

    // MARK: - Private Methods
    @MainActor
    private func fetchStoreDetail(store: StoreDetailStore) async {
        do {
            let result = try await NetworkManager.shared.fetch(
                StoreRouter.detail(query: StoreIDRequest(id: store.state.storeID)),
                successType: StoreDetailResponse.self,
                failureType: CommonMessageResponse.self
            )

            if let success = result.success {
                store.send(.fetchedStoreDetail(success))

                let stateEntity = success.toState().entity
                store.send(.loadMenuImages(items: stateEntity.menuItems))
                store.send(.loadCarouselImages(imageURLs: stateEntity.imageCarousel.imageURLs))
            } else if let failure = result.failure {
                store.send(.fetchStoreDetailFailed("서버 오류: \(failure.message)"))
            } else {
                store.send(.fetchStoreDetailFailed("알 수 없는 오류: 응답이 비어 있음"))
            }
        } catch {
            store.send(.fetchStoreDetailFailed("네트워크 오류: \(error.localizedDescription)"))
        }
    }

    @MainActor
    private func handleOrderSubmission(store: StoreDetailStore) async {
        guard let orderRequest = store.state.createOrderRequest() else {
            print("❌ 장바구니가 비어있어 주문할 수 없습니다.")
            return
        }

        store.send(.orderRequestCreated(orderRequest))
        store.send(.orderSubmissionStarted)

        do {
            let result = try await NetworkManager.shared.fetch(
                OrderRouter.submitOrder(request: orderRequest),
                successType: OrderResponse.self,
                failureType: CommonMessageResponse.self
            )

            if let success = result.success {
                store.send(.orderSubmissionSucceeded(success))

                let paymentInfo = PaymentInfoEntity(
                    orderID: success.order_id,
                    orderCode: success.order_code,
                    totalPrice: success.total_price,
                    storeName: store.state.entity.summary.name,
                    menuItems: Array(store.state.cartItems.values),
                    createdAt: success.createdAt
                )
                store.send(.navigateToPayment(paymentInfo))

            } else if let failure = result.failure {
                store.send(.orderSubmissionFailed(failure.message))
            } else {
                store.send(.orderSubmissionFailed("알 수 없는 오류가 발생했습니다."))
            }
        } catch {
            store.send(.orderSubmissionFailed("네트워크 오류: \(error.localizedDescription)"))
        }
    }

    @MainActor
    private func handleLikeOptimistic(store: StoreDetailStore) async {
        let currentLikeStatus = store.state.entity.imageCarousel.isLiked
        let newLikeStatus = !currentLikeStatus

        print("🚀 [Optimistic UI 시작] \(currentLikeStatus) → \(newLikeStatus)")

        store.send(.likeOptimistic(isLiked: newLikeStatus))
        store.send(.setLikeLoading(isLoading: true))

        let request = StoreLikeRequest(like_status: newLikeStatus)

        do {
            let result = try await NetworkManager.shared.fetch(
                StoreRouter.like(query: StoreIDRequest(id: store.state.storeID), request: request),
                successType: StoreLikeResponse.self,
                failureType: CommonMessageResponse.self
            )

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
        } catch {
            print("📦 [네트워크 에러 - 롤백]: \(error)")
            store.send(.setLikeLoading(isLoading: false))
            store.send(.likeRollback(isLiked: currentLikeStatus))
            store.send(.likeFailed(errorMessage: error.localizedDescription))
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
