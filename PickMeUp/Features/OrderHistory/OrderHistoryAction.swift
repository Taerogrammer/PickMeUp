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
    }

    enum Result {
        case ordersLoading
        case currentOrdersLoaded([OrderData])
        case pastOrdersLoaded([OrderData])
        case ordersLoadingFailed(String)
        case orderTypeSelected(OrderType)
        case refreshCompleted
    }
}
