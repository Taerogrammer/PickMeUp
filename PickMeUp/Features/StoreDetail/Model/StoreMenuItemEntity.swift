//
//  StoreMenuItemEntity.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreMenuItemEntity: Equatable, Hashable {
    let menuID: String
    let storeID: String
    let category: String
    let name: String
    let description: String
    let originInformation: String
    let price: Int
    let isSoldOut: Bool
    let menuImageURL: String
}
