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
        case .tapBack: break
        default: break
        }
    }

    func reduce(state: inout StoreDetailState, result: StoreDetailAction.Result) {
        switch result {
        case .fetchedStoreDetail(let response):
            state = response.toState()

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
        }
    }
}
