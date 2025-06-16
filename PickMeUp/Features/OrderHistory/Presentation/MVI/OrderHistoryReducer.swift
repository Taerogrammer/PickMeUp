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
        case .onAppear:
            state.isLoading = true
            state.errorMessage = nil

        case .selectOrderType(let orderType):
            state.selectedOrderType = orderType

        case .refresh:
            state.isRefreshing = true
            state.errorMessage = nil

        case .pullToRefresh:
            state.isRefreshing = true
            state.errorMessage = nil

        case .updateOrderStatus:
            state.errorMessage = nil

        case .requestNotificationPermission:
            break

        case .loadMenuImage:
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

        case .refreshCompleted:
            state.isRefreshing = false

        case .orderStatusUpdated(let orderCode, let newStatus):
            if let index = state.currentOrders.firstIndex(where: { $0.orderCode == orderCode }) {
                state.currentOrders[index].orderStatus = newStatus
                updateOrderTimeline(order: &state.currentOrders[index], newStatus: newStatus)
            }
            state.errorMessage = nil

        case .orderStatusUpdateFailed(let orderCode, let error):
            state.errorMessage = "[\(orderCode)] 상태 변경 실패: \(error)"

        case .orderCompleted(let orderCode):
            if let index = state.currentOrders.firstIndex(where: { $0.orderCode == orderCode }) {
                var completedOrder = state.currentOrders[index]
                completedOrder.orderStatus = "PICKED_UP"

                state.currentOrders.remove(at: index)
                state.pastOrders.insert(completedOrder, at: 0)
            }
            state.errorMessage = nil

        case .notificationPermissionUpdated(let granted):
            state.hasNotificationPermission = granted

        case .menuImageLoaded(let orderCode, let menuID, let image):
            if state.menuImages[orderCode] == nil {
                state.menuImages[orderCode] = [:]
            }
            state.menuImages[orderCode]?[menuID] = image

        case .menuImageLoadFailed(let orderCode, let menuID, let error):
            print("❌ 메뉴 이미지 로딩 실패: [\(orderCode)][\(menuID)] \(error)")
        }
    }

    // Helper function
    private func updateOrderTimeline(order: inout OrderDataEntity, newStatus: String) {
        if let index = order.orderStatusTimeline.firstIndex(where: { $0.status == newStatus }) {
            order.orderStatusTimeline[index].completed = true
            order.orderStatusTimeline[index].changedAt = ISO8601DateFormatter().string(from: Date())
        }
    }
}
