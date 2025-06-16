//
//  OrderHistoryResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import Foundation

struct OrderHistoryResponse: Decodable {
    let data: [OrderData]
}

extension OrderHistoryResponse {
    func toEntity() -> [OrderStatusEntity] {
        return data.map { $0.toStatusEntity() }
    }
}

struct OrderData: Decodable {
    let orderID: String
    let orderCode: String
    let totalPrice: Int
    let review: Review?
    let store: Store
    let orderMenuList: [OrderMenu]
    let orderStatus: String
    let orderStatusTimeline: [OrderStatusTimeline]
    let paidAt: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case orderID = "order_id"
        case orderCode = "order_code"
        case totalPrice = "total_price"
        case review, store
        case orderMenuList = "order_menu_list"
        case orderStatus = "current_order_status"
        case orderStatusTimeline = "order_status_timeline"
        case paidAt, createdAt, updatedAt
    }
}

extension OrderData {
    func toStatusEntity() -> OrderStatusEntity {
        return OrderStatusEntity(
            orderID: orderID,
            orderCode: orderCode,
            totalPrice: totalPrice,
            store: store.toEntity(),
            orderMenuList: orderMenuList.map { $0.toEntity() },
            orderStatusTimeline: orderStatusTimeline.map { $0.toEntity() },
            createdAt: createdAt
        )
    }
}

extension OrderData {
    func toDataEntity() -> OrderDataEntity {
        return OrderDataEntity(
            orderID: orderID,
            orderCode: orderCode,
            totalPrice: totalPrice,
            review: review?.toEntity(),
            store: store.toEntity(),
            orderMenuList: orderMenuList.map { $0.toEntity() },
            orderStatus: orderStatus,
            orderStatusTimeline: orderStatusTimeline.map { $0.toEntity() },
            paidAt: paidAt,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

struct Review: Decodable {
    let id: String
    let rating: Int
}

extension Review {
    func toEntity() -> ReviewEntity {
        return ReviewEntity(
            id: id,
            rating: rating
        )
    }
}

struct Store: Decodable {
    let id: String
    let category: String
    let name: String
    let close: String
    let storeImageUrls: [String]
    let hashTags: [String]
    let geolocation: Geolocation
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, category, name, close
        case storeImageUrls = "store_image_urls"
        case hashTags, geolocation, createdAt, updatedAt
    }
}

extension Store {
    func toEntity() -> StoreEntity {
        return StoreEntity(
            id: id,
            category: category,
            name: name,
            close: close,
            storeImageUrls: storeImageUrls,
            hashTags: hashTags,
            geolocation: geolocation.toEntity(),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

struct Menu: Decodable {
    let id: String
    let category: String
    let name: String
    let description: String
    let originInformation: String
    let price: Int
    let tags: [String]
    let menuImageUrl: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, category, name, description, price, tags, createdAt, updatedAt
        case originInformation = "origin_information"
        case menuImageUrl = "menu_image_url"
    }
}

struct OrderStatusTimeline: Decodable {
    let status: String
    let completed: Bool
    let changedAt: String?
}

extension OrderStatusTimeline {
    func toEntity() -> OrderStatusTimelineEntity {
        return OrderStatusTimelineEntity(
            status: status,
            completed: completed,
            changedAt: changedAt
        )
    }
}


extension Geolocation {
    func toEntity() -> GeolocationEntity {
        return GeolocationEntity(
            longitude: longitude,
            latitude: latitude
        )
    }
}
