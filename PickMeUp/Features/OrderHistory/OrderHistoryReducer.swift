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
        case .updateOrderStatus:
            break
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

        case .orderTypeSelected(let orderType):
            state.selectedOrderType = orderType

        case .refreshCompleted:
            state.isRefreshing = false

        // 🔥 주문 상태 변경 Result 처리 (Entity 기반)
        case .orderStatusUpdated(let orderCode, let newStatus):
            // 현재 주문에서 해당 주문 찾아서 상태 업데이트
            if let index = state.currentOrders.firstIndex(where: { $0.orderCode == orderCode }) {
                state.currentOrders[index].orderStatus = newStatus

                // orderStatusTimeline도 업데이트
                updateOrderTimeline(order: &state.currentOrders[index], newStatus: newStatus)
            }
            state.errorMessage = nil

        case .orderStatusUpdateFailed(let orderCode, let error):
            state.errorMessage = "[\(orderCode)] 상태 변경 실패: \(error)"

        case .orderCompleted(let orderCode):
            // 현재 주문에서 제거하고 과거 주문에 추가
            if let index = state.currentOrders.firstIndex(where: { $0.orderCode == orderCode }) {
                var completedOrder = state.currentOrders[index]
                completedOrder.orderStatus = "PICKED_UP"

                state.currentOrders.remove(at: index)
                state.pastOrders.insert(completedOrder, at: 0) // 최신 순으로 추가
            }
            state.errorMessage = nil

        case .notificationPermissionUpdated(let granted):
            state.hasNotificationPermission = granted

        // 🔥 이미지 로딩 결과 처리
        case .menuImageLoaded(let orderCode, let menuID, let image):
            if state.menuImages[orderCode] == nil {
                state.menuImages[orderCode] = [:]
            }
            state.menuImages[orderCode]?[menuID] = image

        case .menuImageLoadFailed(let orderCode, let menuID, let error):
            print("❌ 메뉴 이미지 로딩 실패: [\(orderCode)][\(menuID)] \(error)")
        }
    }

    // 주문 타임라인 업데이트 헬퍼 함수 (Entity 기반)
    private func updateOrderTimeline(order: inout OrderDataEntity, newStatus: String) {
        // 해당 상태의 타임라인을 completed로 변경하고 현재 시간으로 설정
        if let index = order.orderStatusTimeline.firstIndex(where: { $0.status == newStatus }) {
            order.orderStatusTimeline[index].completed = true
            order.orderStatusTimeline[index].changedAt = ISO8601DateFormatter().string(from: Date())
        }
    }
}
