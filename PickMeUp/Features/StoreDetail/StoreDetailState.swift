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
    var images: [UIImage] = []
    var totalPrice: Int = 0
    var totalCount: Int = 0

    var loadedMenuImages: [String: UIImage] = [:]
    var loadedCarouselImages: [String: UIImage] = [:]

    var cartItems: [String: CartItem] = [:]
    var selectedMenu: StoreMenuItemEntity?
    var tempQuantity: Int = 1
    var isMenuSheetPresented: Bool = false

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
        return cartItems.count // 메뉴 종류 수
    }

    var menuTotalPrice: Int {
        guard let menu = selectedMenu else { return 0 }
        return menu.price * tempQuantity
    }

    func getCartQuantity(for menuID: String) -> Int {
        return cartItems[menuID]?.quantity ?? 0
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
