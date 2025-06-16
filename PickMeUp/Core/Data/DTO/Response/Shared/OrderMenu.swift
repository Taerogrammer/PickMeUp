//
//  OrderMenu.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import Foundation

struct OrderMenu: Decodable {
    let menu: MenuInfo
    let quantity: Int
}

extension OrderMenu {
    func toEntity() -> OrderMenuEntity {
        return OrderMenuEntity(
            menu: menu.toEntity(),
            quantity: quantity
        )
    }
}
