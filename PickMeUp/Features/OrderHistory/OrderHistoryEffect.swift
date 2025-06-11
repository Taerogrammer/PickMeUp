//
//  OrderHistoryEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import Foundation

struct OrderHistoryEffect {
    func handle(_ action: OrderHistoryAction.Intent, store: OrderHistoryStore) {
        switch action {
        case .viewOnAppear:
            Task {
                await loadInitialOrders(store: store)
            }

        case .selectOrderType(let orderType):
            store.send(.orderTypeSelected(orderType))

        case .refreshOrders:
            Task {
                await refreshAllOrders(store: store)
            }

        case .pullToRefresh:
            Task {
                await refreshAllOrders(store: store)
            }
        }
    }

    private func loadInitialOrders(store: OrderHistoryStore) async {
        await MainActor.run {
            store.send(.ordersLoading)
        }

        do {
            let response = try await NetworkManager.shared.fetch(
                OrderRouter.orderHistory,
                successType: OrderHistoryResponse.self,
                failureType: CommonMessageResponse.self
            )

            if let orderHistory = response.success {
                // 주문 상태에 따라 현재/과거 주문 분리
                let currentOrders = orderHistory.data.filter { order in
                    ["PENDING_APPROVAL", "APPROVED", "IN_PROGRESS", "READY_FOR_PICKUP"].contains(order.currentOrderStatus)
                }

                let pastOrders = orderHistory.data.filter { order in
                    order.currentOrderStatus == "PICKED_UP"
                }

                await MainActor.run {
                    store.send(.currentOrdersLoaded(currentOrders))
                    store.send(.pastOrdersLoaded(pastOrders))
                    print("✅ [OrderHistoryEffect] 주문 내역 로드 성공 - 진행중: \(currentOrders.count)개, 과거: \(pastOrders.count)개")
                }
            } else if let error = response.failure {
                await MainActor.run {
                    store.send(.ordersLoadingFailed(error.message))
                    print("❌ [OrderHistoryEffect] 주문 내역 로드 실패: \(error.message)")
                }
            }
        } catch {
            await MainActor.run {
                store.send(.ordersLoadingFailed(error.localizedDescription))
                print("❌ [OrderHistoryEffect] 주문 내역 로드 에러: \(error.localizedDescription)")
            }
        }
    }

    private func refreshAllOrders(store: OrderHistoryStore) async {
        do {
            let response = try await NetworkManager.shared.fetch(
                OrderRouter.orderHistory,
                successType: OrderHistoryResponse.self,
                failureType: CommonMessageResponse.self
            )

            if let orderHistory = response.success {
                // 주문 상태에 따라 현재/과거 주문 분리
                let currentOrders = orderHistory.data.filter { order in
                    ["PENDING_APPROVAL", "APPROVED", "IN_PROGRESS", "READY_FOR_PICKUP"].contains(order.currentOrderStatus)
                }

                let pastOrders = orderHistory.data.filter { order in
                    order.currentOrderStatus == "PICKED_UP"
                }

                await MainActor.run {
                    store.send(.currentOrdersLoaded(currentOrders))
                    store.send(.pastOrdersLoaded(pastOrders))
                    store.send(.refreshCompleted)
                    print("✅ [OrderHistoryEffect] 주문 내역 새로고침 성공 - 진행중: \(currentOrders.count)개, 과거: \(pastOrders.count)개")
                }
            } else if let error = response.failure {
                await MainActor.run {
                    store.send(.ordersLoadingFailed(error.message))
                    store.send(.refreshCompleted)
                    print("❌ [OrderHistoryEffect] 주문 내역 새로고침 실패: \(error.message)")
                }
            }
        } catch {
            await MainActor.run {
                store.send(.ordersLoadingFailed(error.localizedDescription))
                store.send(.refreshCompleted)
                print("❌ [OrderHistoryEffect] 주문 내역 새로고침 에러: \(error.localizedDescription)")
            }
        }
    }
}
