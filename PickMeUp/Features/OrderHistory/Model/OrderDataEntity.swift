//
//  OrderDataEntity.swift
//  PickMeUp
//
//  Created by 김태형 on 6/11/25.
//

import Foundation

struct OrderDataEntity {
    let orderID: String
    let orderCode: String
    let totalPrice: Int
    let review: ReviewEntity?
    let store: StoreEntity
    let orderMenuList: [OrderMenuEntity]
    var orderStatus: String // 🔥 var
    var orderStatusTimeline: [OrderStatusTimelineEntity] // 🔥 var
    let paidAt: String
    let createdAt: String
    let updatedAt: String
}

struct OrderStatusTimelineEntity {
    let status: String
    var completed: Bool // 🔥 var
    var changedAt: String? // 🔥 var
}

struct StoreEntity {
    let id: String
    let category: String
    let name: String
    let close: String
    let storeImageUrls: [String]
    let hashTags: [String]
    let geolocation: GeolocationEntity
    let createdAt: String
    let updatedAt: String
}

struct OrderMenuEntity {
    let menu: MenuInfoEntity
    let quantity: Int
}

struct MenuInfoEntity {
    let id: String
//    let category: String
    let name: String
//    let description: String
//    let originInformation: String
    let price: Int
//    let tags: [String]
    let menuImageUrl: String
//    let createdAt: String
//    let updatedAt: String
}

struct GeolocationEntity {
    let longitude: Double
    let latitude: Double
}

struct ReviewEntity {
    let id: String
    let rating: Int
}
