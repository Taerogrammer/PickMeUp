//
//  StoreDetailResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import SwiftUI

struct StoreDetailResponse: Decodable {
    let storeID: String
    let category: String
    let name: String
    let description: String
    let hashTags: [String]
    let open: String
    let close: String
    let address: String
    let estimatedPickupTime: Int
    let parkingGuide: String
    let storeImageURLs: [String]
    let isPicchelin: Bool
    let isPick: Bool
    let pickCount: Int
    let totalReviewCount: Int
    let totalOrderCount: Int
    let totalRating: Double
    let creator: Creator
    let geolocation: Geolocation
    let menuList: [MenuResponse]
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case storeID = "store_id"
        case category, name, description, hashTags, open, close, address
        case estimatedPickupTime = "estimated_pickup_time"
        case parkingGuide = "parking_guide"
        case storeImageURLs = "store_image_urls"
        case isPicchelin = "is_picchelin"
        case isPick = "is_pick"
        case pickCount = "pick_count"
        case totalReviewCount = "total_review_count"
        case totalOrderCount = "total_order_count"
        case totalRating = "total_rating"
        case creator, geolocation
        case menuList = "menu_list"
        case createdAt, updatedAt
    }
}

extension StoreDetailResponse {
    func toScreenEntity() -> StoreDetailScreenEntity {
        return StoreDetailScreenEntity(
            storeID: storeID,
            summary: StoreSummaryInfoEntity(
                name: name,
                isPickchelin: isPicchelin,
                pickCount: pickCount,
                totalRating: totalRating,
                totalReviewCount: totalReviewCount,
                totalOrderCount: totalOrderCount
            ),
            detailInfo: StoreDetailInfoEntity(
                address: address,
                open: open,
                close: close,
                parkingGuide: parkingGuide
            ),
            estimatedTime: StoreEstimatedTimeEntity(
                estimatedPickupTime: estimatedPickupTime,
                distance: "" // 거리 계산 필요시 후처리
            ),
            imageCarousel: StoreImageCarouselEntity(
                imageURLs: storeImageURLs,
                isLiked: isPick
            ),
            categoryTab: StoreMenuCategoryTabEntity(
                selectedCategory: "전체",
                categories: ["전체"] + Array(Set(menuList.map { $0.category }))
            ),
            menuItems: menuList.map { $0.toEntity() },
            storeMenuListEntity: StoreMenuListEntity(
                menus: menuList.map { $0.toMenuItem() }
            ),
            bottomBar: StoreBottomBarEntity(
                totalPrice: 0,
                itemCount: 0
            )
        )
    }
}

extension MenuResponse {
    func toEntity() -> StoreMenuItemEntity {
        return StoreMenuItemEntity(
            menuID: menuID,
            storeID: storeID,
            category: category,
            name: name,
            description: description,
            originInformation: originInformation,
            price: price,
            isSoldOut: isSoldOut,
            menuImageURL: menuImageURL
        )
    }
}

extension StoreDetailResponse {
    func toState() -> StoreDetailState {
        StoreDetailState(
            storeID: storeID,
            entity: self.toScreenEntity(),
            selectedCategory: "전체",
            images: [],
            totalPrice: 0,
            totalCount: 0
        )
    }
}

extension StoreDetailResponse {
    static func mock() -> StoreDetailResponse {
        return StoreDetailResponse(
            storeID: "68232364ca81ef0db5a4628d",
            category: "패스트푸드",
            name: "새싹 치킨 관악점",
            description: "매일 새로운 기름을 써서 신선한 새싹 치킨",
            hashTags: ["#오늘은치킨이닭"],
            open: "11:00",
            close: "22:00",
            address: "서울특별시 도봉구 창제5동 258-10",
            estimatedPickupTime: 49,
            parkingGuide: "인근 공영 주차장 활용",
            storeImageURLs: [
                "/data/stores/alexandra-tran-oXULSch338E-unsplash_1747128618331.jpg",
                "/data/stores/d-pham-MU0pYUnrT68-unsplash_1747128618513.jpg",
                "/data/stores/deepthi-clicks--UUkXJIXgy4-unsplash_1747128618888.jpg"
            ],
            isPicchelin: false,
            isPick: true,
            pickCount: 2,
            totalReviewCount: 0,
            totalOrderCount: 0,
            totalRating: 0.0,
            creator: Creator(
                userID: "6822cbc42d09c906968d876f",
                nick: "휴사장님"
            ),
            geolocation: Geolocation(
                longitude: 127.049852,
                latitude: 37.654112
            ),
            menuList: [
                MenuResponse(
                    menuID: "6823279cca81ef0db5a46332",
                    storeID: "68232364ca81ef0db5a4628d",
                    category: "카테고리 1",
                    name: "새싹 바사삭 1",
                    description: "한 입 베어 물면 바삭! 육즙이 터지는 황홀함까지! 진짜 맛있는 치킨은 이유 없이 자꾸 생각나요.",
                    originInformation: "닭: 국산, 밀가루: 호주산",
                    price: 1800,
                    isSoldOut: false,
                    tags: [],
                    menuImageURL: "/data/menus/1747133821135.png",
                    createdAt: "2025-05-13T10:20:00.000Z", // 임의 값
                    updatedAt: "2025-05-13T10:21:00.000Z"
                ),
                MenuResponse(
                    menuID: "68231de4ca81ef0db5a460c8",
                    storeID: "68232364ca81ef0db5a4628d",
                    category: "카테고리 2",
                    name: "새싹 콜라",
                    description: "맛있는 빵",
                    originInformation: "밀가루: 호주산, 설탕: 미국산",
                    price: 1050,
                    isSoldOut: false,
                    tags: ["인기 1위"],
                    menuImageURL: "/data/menus/1747131220328.jpg",
                    createdAt: "2025-05-13T10:22:00.000Z",
                    updatedAt: "2025-05-13T10:23:00.000Z"
                )
            ],
            createdAt: "2025-05-13T10:19:00.000Z",
            updatedAt: "2025-05-13T10:24:00.000Z"
        )
    }
}
