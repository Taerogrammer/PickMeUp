//
//  OrderResponse.swift
//  PickMeUp
//
//  Created by 김태형 on 6/8/25.
//

import Foundation

struct OrderResponse: Codable {
    let order_id: String
    let order_code: String
    let total_price: Int
    let createdAt: String
    let updatedAt: String
}
