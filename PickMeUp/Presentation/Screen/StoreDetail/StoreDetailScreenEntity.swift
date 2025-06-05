//
//  StoreDetailScreenEntity.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import Foundation

struct StoreDetailScreenEntity {
    let storeID: String
    let summary: StoreSummaryInfoEntity
    let detailInfo: StoreDetailInfoEntity
    let estimatedTime: StoreEstimatedTimeEntity
    let imageCarousel: StoreImageCarouselEntity
    let categoryTab: StoreMenuCategoryTabEntity
    let menuItems: [StoreMenuItemEntity]
    let storeMenuListEntity: StoreMenuListEntity
    let bottomBar: StoreBottomBarEntity
}

extension StoreDetailScreenEntity {
    static func placeholder(storeID: String) -> StoreDetailScreenEntity {
        StoreDetailScreenEntity(
            storeID: storeID,
            summary: StoreSummaryInfoEntity(
                name: "",
                isPickchelin: false,
                pickCount: 0,
                rating: 0.0
            ),
            detailInfo: StoreDetailInfoEntity(
                address: "",
                open: "",
                close: "",
                parkingGuide: ""
            ),
            estimatedTime: StoreEstimatedTimeEntity(
                estimatedPickupTime: 0,
                distance: ""
            ),
            imageCarousel: StoreImageCarouselEntity(
                imageURLs: [],
                isLiked: false
            ),
            categoryTab: StoreMenuCategoryTabEntity(
                selectedCategory: "전체",
                categories: []
            ),
            menuItems: [],
            storeMenuListEntity: StoreMenuListEntity(menus: []),
            bottomBar: StoreBottomBarEntity(
                totalPrice: 0,
                itemCount: 0
            )
        )
    }
}
