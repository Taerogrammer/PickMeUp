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
    var imageLoadErrors: [String: String] = [:]

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

// MARK: - 필터 상태 비교를 위한 구조체
private struct FilterState: Equatable {
    let category: String
    let isPickchelinOn: Bool
    let isMyPickOn: Bool
    let storesCount: Int
}

// MARK: - StoreListState 확장 (캐싱 기능 추가)
extension StoreListState {
    // 캐시된 필터링 결과
    private static var _cachedFilteredStores: [StorePresentable] = []
    private static var _lastFilterState: FilterState?

    var optimizedFilteredStores: [StorePresentable] {
        let currentFilterState = FilterState(
            category: selectedCategory,
            isPickchelinOn: isPickchelinOn,
            isMyPickOn: isMyPickOn,
            storesCount: stores.count
        )

        // 필터 상태가 변경되었을 때만 재계산
        if Self._lastFilterState != currentFilterState {
            Self._cachedFilteredStores = computeFilteredStores()
            Self._lastFilterState = currentFilterState
        }

        return Self._cachedFilteredStores
    }

    private func computeFilteredStores() -> [StorePresentable] {
        var filtered = selectedCategory == "전체" ? stores : stores.filter { $0.category == selectedCategory }
        if isPickchelinOn { filtered = filtered.filter { $0.isPicchelin } }
        if isMyPickOn { filtered = filtered.filter { $0.isPick } }
        return filtered
    }
}
