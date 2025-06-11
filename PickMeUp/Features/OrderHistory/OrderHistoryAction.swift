//
//  OrderHistoryAction.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import Foundation

enum OrderHistoryAction {
    enum Intent {
        case viewOnAppear
        case selectOrderType(OrderType)
        case refreshOrders
        case pullToRefresh
        case updateOrderStatus(orderCode: String, currentStatus: String)
        case requestNotificationPermission
    }

    enum Result {
        case ordersLoading
        case currentOrdersLoaded([OrderDataEntity]) // 🔥 Entity로 변경
        case pastOrdersLoaded([OrderDataEntity]) // 🔥 Entity로 변경
        case ordersLoadingFailed(String)
        case orderTypeSelected(OrderType)
        case refreshCompleted
        case orderStatusUpdated(orderCode: String, newStatus: String)
        case orderStatusUpdateFailed(orderCode: String, error: String)
        case orderCompleted(orderCode: String)
        case notificationPermissionUpdated(Bool)
    }
}
