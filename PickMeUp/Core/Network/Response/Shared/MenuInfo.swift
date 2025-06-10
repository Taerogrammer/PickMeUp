//
//  MenuInfo.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import Foundation

struct MenuInfo: Decodable {
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

extension MenuInfo {
    func toEntity() -> MenuInfoEntity {
        return MenuInfoEntity(
            id: id,
            name: name,
            price: price,
            menuImageUrl: menuImageUrl
        )
    }
}
