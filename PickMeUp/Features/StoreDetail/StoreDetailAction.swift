//
//  StoreDetailAction.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import SwiftUI

enum StoreDetailAction {
    enum Intent {
        case onAppear
        case selectCategory(String)
        case tapNavigation
        case tapPay
        case tapBack
        case tapLike
        case loadMenuImages(items: [StoreMenuItemEntity])
        case loadCarouselImages(imageURLs: [String])
    }

    enum Result {
        case fetchedStoreDetail(StoreDetailResponse)
        case loadCarouselImageSuccess(imageURL: String, image: UIImage)
        case loadCarouselImageFailed(imageURL: String, errorMessage: String)
        case loadMenuImageSuccess(menuID: String, image: UIImage)
        case loadMenuImageFailed(menuID: String, errorMessage: String)
        case likeSuccess(isLiked: Bool)                    // 서버 확인 후 최종 업데이트
        case likeOptimistic(isLiked: Bool)                 // 즉시 UI 업데이트 (새로 추가)
        case likeRollback(isLiked: Bool)                   // 실패 시 롤백 (새로 추가)
        case likeFailed(errorMessage: String)
        case setLikeLoading(isLoading: Bool)
    }
}
