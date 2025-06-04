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

    enum CodingKeys: String, CodingKey {
        case menuID = "menu_id"
        case storeID = "store_id"
        case category, name, description
        case originInformation = "origin_information"
        case price
        case isSoldOut = "is_sold_out"
        case tags
        case menuImageURL = "menu_image_url"
    }
}

extension MenuResponse {
    func toMenuItem() -> MenuItem {
        return MenuItem(
            name: name,
            description: description,
            image: UIImage(systemName: "photo")!,
            isPopular: false,
            rank: 0,
            category: category,
            price: price,
            isSoldOut: isSoldOut
        )
    }
}
