//
//  StoreDetailState.swift
//  PickMeUp
//
//  Created by 김태형 on 6/4/25.
//

import SwiftUI

struct StoreDetailState {
    let storeID: String
    var isLiked: Bool = false

    var name: String = ""
    var isPickchelin: Bool = false
    var likeCount: Int = 0
    var rating: Double = 0
    var address: String = ""
    var openHour: String = ""
    var parkingAvailable: String = ""
    var estimatedTime: String = ""
    var distance: String = ""
    var categories: [String] = []
    var selectedCategory: String = "전체"
    var menus: [MenuItem] = []
    var images: [UIImage] = []
    var totalPrice: Int = 0
    var totalCount: Int = 0

    var filteredMenus: [MenuItem] {
        selectedCategory == "전체" ? menus : menus.filter { $0.category == selectedCategory }
    }
}
