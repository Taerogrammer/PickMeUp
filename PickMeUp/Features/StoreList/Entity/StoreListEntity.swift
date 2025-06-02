//
//  StoreListEntity.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import Foundation

struct StoreListEntity: StorePresentable {
    let storeID: String
    let category: String
    let name: String
    let close: String
    let storeImageURLs: [String]
    let isPicchelin: Bool
    let isPick: Bool
    let pickCount: Int
    let hashTags: [String]
    let totalRating: Double
    let totalOrderCount: Int
    let totalReviewCount: Int
    let distance: Double
}
