//
//  StoreListResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 6/1/25.
//

import Foundation

struct StoreListResponse: Decodable {
    let data: [StoreModel]
    let nextCursor: String?

    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

struct StoreModel: Decodable, Identifiable {
    var id: String { storeID }

    let storeID: String
    let category: String
    let name: String
    let close: String
    let storeImageUrls: [String]
    let isPicchelin: Bool
    let isPick: Bool
    let pickCount: Int
    let hashTags: [String]
    let totalRating: Double
    let totalOrderCount: Int
    let totalReviewCount: Int
    let geolocation: Geolocation
    let distance: Double
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case storeID = "store_id"
        case category, name, close
        case storeImageUrls = "store_image_urls"
        case isPicchelin = "is_picchelin"
        case isPick = "is_pick"
        case pickCount = "pick_count"
        case hashTags
        case totalRating = "total_rating"
        case totalOrderCount = "total_order_count"
        case totalReviewCount = "total_review_count"
        case geolocation, distance, createdAt, updatedAt
    }
}

extension StoreModel {
    func toStoreListEntity() -> StoreListEntity {
        return StoreListEntity(
            storeID: storeID,
            category: category,
            name: name,
            close: close,
            storeImageURLs: storeImageUrls,
            isPicchelin: isPicchelin,
            isPick: isPick,
            pickCount: pickCount,
            hashTags: hashTags,
            totalRating: totalRating,
            totalOrderCount: totalOrderCount,
            totalReviewCount: totalReviewCount,
            distance: distance
        )
    }
}
