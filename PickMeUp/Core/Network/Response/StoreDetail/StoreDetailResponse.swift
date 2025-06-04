//
//  StoreDetailResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import Foundation

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
                    menuImageURL: "/data/menus/1747133821135.png"
                )
            ]
        )
    }
}
