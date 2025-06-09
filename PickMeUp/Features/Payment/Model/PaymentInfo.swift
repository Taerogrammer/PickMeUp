//
//  PaymentInfo.swift
//  PickMeUp
//
//  Created by 김태형 on 6/9/25.
//

import Foundation

struct PaymentInfo: Equatable, Hashable {
    let orderID: String
    let orderCode: String
    let totalPrice: Int
    let storeName: String
    let menuItems: [CartItem]
    let createdAt: String
}
