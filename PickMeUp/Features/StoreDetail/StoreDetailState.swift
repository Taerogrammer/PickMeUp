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

    var selectedCategory: String = "전체"
    var images: [UIImage] = []
    var totalPrice: Int = 0
    var totalCount: Int = 0

    var loadedMenuImages: [String: UIImage] = [:]
    var loadedCarouselImages: [String: UIImage] = [:] // 추가

    var filteredMenus: [StoreMenuItemEntity] {
        if selectedCategory == "전체" {
            return entity.menuItems
        }
        return entity.menuItems.filter { $0.category == selectedCategory }
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
            loadedImages: loadedCarouselImages
        )
    }

    var storeMenuCategoryTabEntity: StoreMenuCategoryTabEntity {
        .init(selectedCategory: selectedCategory, categories: entity.categoryTab.categories)
    }

    var storeMenuItemEntities: [StoreMenuItemEntity] {
        filteredMenus
    }

    var storeBottomBarEntity: StoreBottomBarEntity {
        .init(totalPrice: totalPrice, itemCount: totalCount)
    }

    var storeMenuListEntity: StoreMenuListEntity {
        StoreMenuListEntity(
            menus: filteredMenus,
            loadedImages: loadedMenuImages
        )
    }
}
