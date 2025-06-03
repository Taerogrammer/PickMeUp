//
//  StoreListState.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import Foundation

struct StoreListState {
    var stores: [StorePresentable] = []
    var selectedCategory: String = "전체"
    var isPickchelinOn: Bool = false
    var isMyPickOn: Bool = false
    var errorMessage: String? = nil

    var filteredStores: [StorePresentable] {
        var filtered = selectedCategory == "전체" ? stores : stores.filter { $0.category == selectedCategory }
        if isPickchelinOn { filtered = filtered.filter { $0.isPicchelin } }
        if isMyPickOn { filtered = filtered.filter { $0.isPick } }
        return filtered
    }

    let categories: [(image: String, title: String)] = [
        ("coffee", "커피"),
        ("hamburger", "패스트푸드"),
        ("desert", "디저트"),
        ("bread", "베이커리")
    ]
}
