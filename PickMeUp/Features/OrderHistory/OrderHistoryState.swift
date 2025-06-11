//
//  OrderHistoryState.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import Foundation

struct OrderHistoryState {
    var selectedOrderType: OrderType = .current
    var currentOrders: [OrderDataEntity] = [] // 🔥 Entity로 변경
    var pastOrders: [OrderDataEntity] = [] // 🔥 Entity로 변경
    var isLoading: Bool = false
    var isRefreshing: Bool = false
    var errorMessage: String? = nil
    var hasNotificationPermission: Bool = false

    // MARK: - Computed Properties
    var currentOrdersCount: Int {
        return currentOrders.count
    }

    var pastOrdersCount: Int {
        return pastOrders.count
    }

    var selectedOrdersCount: Int {
        switch selectedOrderType {
        case .current:
            return currentOrdersCount
        case .past:
            return pastOrdersCount
        }
    }

    var selectedOrders: [OrderDataEntity] { // 🔥 Entity로 변경
        switch selectedOrderType {
        case .current:
            return currentOrders
        case .past:
            return pastOrders
        }
    }

    var hasOrders: Bool {
        return !currentOrders.isEmpty || !pastOrders.isEmpty
    }

    var hasCurrentOrders: Bool {
        return !currentOrders.isEmpty
    }

    var hasPastOrders: Bool {
        return !pastOrders.isEmpty
    }
}
