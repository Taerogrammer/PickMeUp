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

        case showMenuDetail(StoreMenuItemEntity)
        case hideMenuDetail
        case increaseMenuQuantity
        case decreaseMenuQuantity
        case addMenuToCart
        case removeFromCart(String)
        case clearCart

        case navigateToPayment(PaymentInfo)
    }

    enum Result {
        case fetchedStoreDetail(StoreDetailResponse)
        case fetchStoreDetailFailed(String)
        case loadCarouselImageSuccess(imageURL: String, image: UIImage)
        case loadCarouselImageFailed(imageURL: String, errorMessage: String)
        case loadMenuImageSuccess(menuID: String, image: UIImage)
        case loadMenuImageFailed(menuID: String, errorMessage: String)
        case likeSuccess(isLiked: Bool)
        case likeOptimistic(isLiked: Bool)
        case likeRollback(isLiked: Bool)
        case likeFailed(errorMessage: String)
        case setLikeLoading(isLoading: Bool)

        case menuDetailShown(StoreMenuItemEntity)
        case menuDetailHidden
        case menuQuantityUpdated(Int)
        case menuAddedToCart(CartItem)
        case menuRemovedFromCart(String)
        case cartCleared
        case orderRequestCreated(OrderRequest)

        case orderSubmissionStarted
        case orderSubmissionSucceeded(OrderResponse)
        case orderSubmissionFailed(String)

        case paymentNavigationTriggered(PaymentInfo)
    }
}
