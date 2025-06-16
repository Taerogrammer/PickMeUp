//
//  StoreDetailState.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import SwiftUI

struct StoreDetailState {
    let storeID: String
    var entity: StoreDetailScreenEntity
    var isLikeLoading: Bool

    var selectedCategory: String = "전체"
    var isLoading: Bool = false
    var images: [UIImage] = []
    var totalPrice: Int = 0
    var totalCount: Int = 0

    var loadedMenuImages: [String: UIImage] = [:]
    var loadedCarouselImages: [String: UIImage] = [:]

    var cartItems: [String: CartItem] = [:]
    var selectedMenu: StoreMenuItemEntity?
    var tempQuantity: Int = 1
    var isMenuSheetPresented: Bool = false

    var isOrderLoading: Bool = false

    var filteredMenus: [StoreMenuItemEntity] {
        if selectedCategory == "전체" {
            return entity.menuItems
        }
        return entity.menuItems.filter { $0.category == selectedCategory }
    }

    var cartTotalPrice: Int {
        return cartItems.values.reduce(0) { $0 + $1.totalPrice }
    }

    var cartItemCount: Int {
        return cartItems.count
    }

    var menuTotalPrice: Int {
        guard let menu = selectedMenu else { return 0 }
        return menu.price * tempQuantity
    }

    func getCartQuantity(for menuID: String) -> Int {
        return cartItems[menuID]?.quantity ?? 0
    }

    func createOrderRequest() -> OrderRequest? {
        guard !cartItems.isEmpty else { return nil }

        let orderMenuList = cartItems.values.map { cartItem in
            OrderMenuItem(
                menu_id: cartItem.menu.menuID,
                quantity: cartItem.quantity
            )
        }

        return OrderRequest(
            store_id: storeID,
            order_menu_list: orderMenuList,
            total_price: cartTotalPrice
        )
    }
}

extension StoreDetailState {
    var storeSummaryInfoEntity: StoreSummaryInfoEntity {
        entity.summary
    }

    var storeDetailInfoEntity: StoreDetailInfoEntity {
        entity.detailInfo
    }

    var storeEstimatedTimeEntity: StoreEstimatedTimeEntity {
        entity.estimatedTime
    }

    var storeImageCarouselEntity: StoreImageCarouselEntity {
        .init(
            imageURLs: entity.imageCarousel.imageURLs,
            isLiked: entity.imageCarousel.isLiked,
            loadedImages: loadedCarouselImages,
            isLikeLoading: isLikeLoading
        )
    }

    var storeMenuCategoryTabEntity: StoreMenuCategoryTabEntity {
        .init(selectedCategory: selectedCategory, categories: entity.categoryTab.categories)
    }

    var storeMenuItemEntities: [StoreMenuItemEntity] {
        filteredMenus
    }

    var storeBottomBarEntity: StoreBottomBarEntity {
        .init(totalPrice: cartTotalPrice, itemCount: cartItemCount)
    }

    var storeMenuListEntity: StoreMenuListEntity {
        StoreMenuListEntity(
            menus: filteredMenus,
            loadedImages: loadedMenuImages
        )
    }
}


extension StoreDetailState {
    var currentPaymentInfo: PaymentInfoEntity? {
        return nil // 필요시 구현
    }
}
