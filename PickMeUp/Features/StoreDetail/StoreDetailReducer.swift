//
//  StoreDetailReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import Foundation

struct StoreDetailReducer {
    func reduce(state: inout StoreDetailState, action: StoreDetailAction.Intent) {
        switch action {
        case .selectCategory(let category):
            state.selectedCategory = category
        case .tapLike:
            break
        case .tapBack:
            break

        case .showMenuDetail(let menu):
            state.selectedMenu = menu
            state.tempQuantity = state.cartItems[menu.menuID]?.quantity ?? 1
            state.isMenuSheetPresented = true

        case .hideMenuDetail:
            state.isMenuSheetPresented = false
            state.selectedMenu = nil
            state.tempQuantity = 1

        case .increaseMenuQuantity:
            state.tempQuantity += 1

        case .decreaseMenuQuantity:
            if state.tempQuantity > 1 {
                state.tempQuantity -= 1
            }

        case .addMenuToCart:
            break // Effect에서 처리

        case .removeFromCart(let menuID):
            state.cartItems.removeValue(forKey: menuID)

        case .clearCart:
            state.cartItems.removeAll()

        default:
            break
        }
    }

    func reduce(state: inout StoreDetailState, result: StoreDetailAction.Result) {
        switch result {
        case .fetchedStoreDetail(let response):
            let newState = response.toState()
            // 기존 장바구니 상태는 유지
            let cartItems = state.cartItems
            state = newState
            state.cartItems = cartItems

        case .loadMenuImageSuccess(let menuID, let image):
            state.loadedMenuImages[menuID] = image

        case .loadMenuImageFailed(_, let errorMessage):
            print("❌ 메뉴 이미지 로딩 실패: \(errorMessage)")

        case .loadCarouselImageSuccess(let imageURL, let image):
            state.loadedCarouselImages[imageURL] = image

        case .loadCarouselImageFailed(let imageURL, let errorMessage):
            print("❌ 캐러셀 이미지 로딩 실패 (\(imageURL)): \(errorMessage)")

        case .likeSuccess(let isLiked):
            state.entity.imageCarousel.isLiked = isLiked
            state.isLikeLoading = false
            print("✅ [서버 확인] 최종 좋아요 상태: \(isLiked)")

        case .likeOptimistic(let isLiked):
            state.entity.imageCarousel.isLiked = isLiked
            print("🚀 [Optimistic UI] 즉시 하트 상태 변경: \(isLiked)")

        case .likeRollback(let isLiked):
            state.entity.imageCarousel.isLiked = isLiked
            state.isLikeLoading = false
            print("🔄 [Rollback] 원래 상태로 복구: \(isLiked)")

        case .likeFailed(let errorMessage):
            state.isLikeLoading = false
            print("❌ 좋아요 처리 실패: \(errorMessage)")

        case .setLikeLoading(let isLoading):
            state.isLikeLoading = isLoading

        // Cart 관련 결과 처리
        case .menuDetailShown(let menu):
            state.selectedMenu = menu
            state.tempQuantity = state.cartItems[menu.menuID]?.quantity ?? 1
            state.isMenuSheetPresented = true

        case .menuDetailHidden:
            state.isMenuSheetPresented = false
            state.selectedMenu = nil
            state.tempQuantity = 1

        case .menuQuantityUpdated(let quantity):
            state.tempQuantity = quantity

        case .menuAddedToCart(let cartItem):
            state.cartItems[cartItem.menu.menuID] = cartItem
            // Sheet 닫기
            state.isMenuSheetPresented = false
            state.selectedMenu = nil
            state.tempQuantity = 1
            print("🛒 장바구니에 추가됨: \(cartItem.menu.name) × \(cartItem.quantity)")

        case .menuRemovedFromCart(let menuID):
            state.cartItems.removeValue(forKey: menuID)
            print("🗑️ 장바구니에서 제거됨: \(menuID)")

        case .cartCleared:
            state.cartItems.removeAll()
            print("🗑️ 장바구니 비워짐")
        }
    }
}
