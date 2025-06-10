//
//  OrderHistoryReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import Foundation

struct OrderHistoryReducer {
    func reduce(state: inout OrderHistoryState, action: OrderHistoryAction.Intent) {
        switch action {
        case .viewOnAppear:
            break
        case .selectOrderType:
            break
        case .refreshOrders:
            break
        case .pullToRefresh:
            break
        }
    }

    func reduce(state: inout OrderHistoryState, result: OrderHistoryAction.Result) {
        switch result {
        case .ordersLoading:
            state.isLoading = true
            state.errorMessage = nil

        case .currentOrdersLoaded(let orders):
            state.currentOrders = orders
            state.isLoading = false
            state.isRefreshing = false
            state.errorMessage = nil

        case .pastOrdersLoaded(let orders):
            state.pastOrders = orders
            state.isLoading = false
            state.isRefreshing = false
            state.errorMessage = nil

        case .ordersLoadingFailed(let error):
            state.isLoading = false
            state.isRefreshing = false
            state.errorMessage = error

        case .orderTypeSelected(let orderType):
            state.selectedOrderType = orderType

        case .refreshCompleted:
            state.isRefreshing = false
        }
    }
}
