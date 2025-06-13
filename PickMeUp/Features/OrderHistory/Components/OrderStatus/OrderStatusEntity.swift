//
//  OrderStatusEntity.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import Foundation

struct OrderStatusEntity {
    let orderID: String
    let orderCode: String
    let totalPrice: Int
    let store: StoreEntity
    let orderMenuList: [OrderMenuEntity]
    let orderStatusTimeline: [OrderStatusTimelineEntity]
    let createdAt: String
}

//struct StoreEntity {
//    let name: String
//}
//
//struct OrderMenuEntity {
//    let menu: MenuInfoEntity
//    let quantity: Int
//}
//
//struct MenuInfoEntity {
//    let id: String
//    let name: String
//    let price: Int
//    let menuImageUrl: String
//}

//struct OrderStatusTimelineEntity {
//    let status: String
//    let completed: Bool
//    let changedAt: String?
//}
