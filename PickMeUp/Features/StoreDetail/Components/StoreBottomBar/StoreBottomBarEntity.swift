//
//  StoreBottomBarEntity.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import Foundation

struct StoreBottomBarEntity {
    let totalPrice: Int
    let itemCount: Int
}

extension StoreBottomBarEntity {
    static func mock() -> StoreBottomBarEntity {
        let menus = StoreDetailResponse.mock().menuList.map { $0.toEntity() }

        // 예시: 모든 메뉴 1개씩 선택했다고 가정
        let totalCount = menus.count
        let totalPrice = menus.reduce(0) { $0 + $1.price }

        return StoreBottomBarEntity(
            totalPrice: totalPrice,
            itemCount: totalCount
        )
    }
}
