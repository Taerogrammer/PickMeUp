//
//  PaymentValidationResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 6/9/25.
//

import Foundation

struct PaymentValidationResponse: Decodable {
    let payment_id: String
    let order_item: OrderItem
    let createdAt: String
    let updatedAt: String
}

struct OrderItem: Decodable {
    let order_id: String
    let order_code: String
    let total_price: Int
    let store: StoreInfo
    let order_menu_list: [OrderMenu]
    let paidAt: String
    let createdAt: String
    let updatedAt: String
}

struct StoreInfo: Decodable {
    let id: String
    let category: String
    let name: String
    let close: String
    let store_image_urls: [String]
    let hashTags: [String]
    let geolocation: Geolocation
    let createdAt: String
    let updatedAt: String
}

struct OrderMenu: Decodable {
    let menu: MenuInfo
    let quantity: Int
}

struct MenuInfo: Decodable {
    let id: String
    let category: String
    let name: String
    let description: String
    let origin_information: String
    let price: Int
    let tags: [String]
    let menu_image_url: String
    let createdAt: String
    let updatedAt: String
}
