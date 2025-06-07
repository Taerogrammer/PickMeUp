//
//  StoreListState.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import SwiftUI

struct StoreListState {
    var stores: [StorePresentable] = []
    var loadedImages: [String: [UIImage]] = [:]

    // 🔑 페이지네이션 상태 추가
    var nextCursor: String? = nil
    var isLoadingMore: Bool = false
    var hasReachedEnd: Bool = false

    var selectedCategory: String
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

    var showFilter: Bool = true
    var showSortButton: Bool = true

    init(
        stores: [StorePresentable] = [],
        loadedImages: [String: [UIImage]] = [:],
        selectedCategory: String = "전체"
    ) {
        self.stores = stores
        self.loadedImages = loadedImages
        self.selectedCategory = selectedCategory
    }
}
