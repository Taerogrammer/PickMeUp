//
//  OrderHistoryAction.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import SwiftUI

enum OrderHistoryAction {
    enum Intent {
        case viewOnAppear
        case selectOrderType(OrderType)
        case refreshOrders
        case pullToRefresh
        case updateOrderStatus(orderCode: String, currentStatus: String)
        case requestNotificationPermission
        case loadMenuImage(orderCode: String, menuID: String, imageUrl: String)
    }

    enum Result {
        case ordersLoading
        case currentOrdersLoaded([OrderDataEntity])
        case pastOrdersLoaded([OrderDataEntity])
        case ordersLoadingFailed(String)
        case orderTypeSelected(OrderType)
        case refreshCompleted
        case orderStatusUpdated(orderCode: String, newStatus: String)
        case orderStatusUpdateFailed(orderCode: String, error: String)
        case orderCompleted(orderCode: String)
        case notificationPermissionUpdated(Bool)
        case menuImageLoaded(orderCode: String, menuID: String, image: UIImage)
        case menuImageLoadFailed(orderCode: String, menuID: String, error: String)
    }
}
