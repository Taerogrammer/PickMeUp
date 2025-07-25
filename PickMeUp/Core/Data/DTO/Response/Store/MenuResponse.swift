//
//  MenuResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import SwiftUI

struct MenuResponse: Decodable {
    let menuID: String
    let storeID: String
    let category: String
    let name: String
    let description: String
    let originInformation: String
    let price: Int
    let isSoldOut: Bool
    let tags: [String]
    let menuImageURL: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case menuID = "menu_id"
        case storeID = "store_id"
        case category, name, description
        case originInformation = "origin_information"
        case price
        case isSoldOut = "is_sold_out"
        case tags
        case menuImageURL = "menu_image_url"
        case createdAt, updatedAt
    }
}

extension MenuResponse {
    func toStoreMenuItemEntity() -> StoreMenuItemEntity {
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
