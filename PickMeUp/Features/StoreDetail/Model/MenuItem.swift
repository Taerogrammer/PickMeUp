//
//  MenuItem.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct MenuItem: Hashable {
    let name: String
    let description: String
    let imageURL: String
    let isPopular: Bool
    let rank: Int
    let category: String
    let price: Int
    let isSoldOut: Bool
}
