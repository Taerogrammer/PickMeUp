//
//  OrderRequest.swift
//  PickMeUp
//
//  Created by 김태형 on 6/8/25.
//

import Foundation

struct OrderRequest: Codable {
    let store_id: String
    let order_menu_list: [OrderMenuItem]
    let total_price: Int
}

struct OrderMenuItem: Codable {
    let menu_id: String
    let quantity: Int
}
