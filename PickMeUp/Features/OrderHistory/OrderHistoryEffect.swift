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
                await requestNotificationPermission(store: store)
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

        // 🔥 주문 상태 변경 처리
        case .updateOrderStatus(let orderCode, let currentStatus):
            Task {
                await updateOrderStatus(orderCode: orderCode, currentStatus: currentStatus, store: store)
            }

        case .requestNotificationPermission:
            Task {
                await requestNotificationPermission(store: store)
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
                // 🔥 Response를 Entity로 변환
                let allOrderEntities = orderHistory.toEntity()

                // 주문 상태에 따라 현재/과거 주문 분리
                let currentOrders = allOrderEntities.filter { order in
                    let currentStatus = order.orderStatusTimeline.last { $0.completed }?.status ?? "PENDING_APPROVAL"
                    return ["PENDING_APPROVAL", "APPROVED", "IN_PROGRESS", "READY_FOR_PICKUP"].contains(currentStatus)
                }

                let pastOrders = allOrderEntities.filter { order in
                    let currentStatus = order.orderStatusTimeline.last { $0.completed }?.status ?? "PENDING_APPROVAL"
                    return currentStatus == "PICKED_UP"
                }

                // Entity 변환
                let currentOrderDataEntities = currentOrders.map { convertToOrderDataEntity($0) }
                let pastOrderDataEntities = pastOrders.map { convertToOrderDataEntity($0) }

                await MainActor.run {
                    store.send(.currentOrdersLoaded(currentOrderDataEntities))
                    store.send(.pastOrdersLoaded(pastOrderDataEntities))
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
                // 🔥 Response를 Entity로 변환
                let allOrderEntities = orderHistory.toEntity()

                // 주문 상태에 따라 현재/과거 주문 분리
                let currentOrders = allOrderEntities.filter { order in
                    let currentStatus = order.orderStatusTimeline.last { $0.completed }?.status ?? "PENDING_APPROVAL"
                    return ["PENDING_APPROVAL", "APPROVED", "IN_PROGRESS", "READY_FOR_PICKUP"].contains(currentStatus)
                }

                let pastOrders = allOrderEntities.filter { order in
                    let currentStatus = order.orderStatusTimeline.last { $0.completed }?.status ?? "PENDING_APPROVAL"
                    return currentStatus == "PICKED_UP"
                }

                // Entity 변환
                let currentOrderDataEntities = currentOrders.map { convertToOrderDataEntity($0) }
                let pastOrderDataEntities = pastOrders.map { convertToOrderDataEntity($0) }

                await MainActor.run {
                    store.send(.currentOrdersLoaded(currentOrderDataEntities))
                    store.send(.pastOrdersLoaded(pastOrderDataEntities))
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

    private func convertToOrderDataEntity(_ orderStatusEntity: OrderStatusEntity) -> OrderDataEntity {
        let currentStatus = orderStatusEntity.orderStatusTimeline.last { $0.completed }?.status ?? "PENDING_APPROVAL"

        return OrderDataEntity(
            orderID: orderStatusEntity.orderID,
            orderCode: orderStatusEntity.orderCode,
            totalPrice: orderStatusEntity.totalPrice,
            review: nil, // OrderStatusEntity에 없으므로 nil
            store: orderStatusEntity.store,
            orderMenuList: orderStatusEntity.orderMenuList,
            orderStatus: currentStatus,
            orderStatusTimeline: orderStatusEntity.orderStatusTimeline,
            paidAt: "", // OrderStatusEntity에 없으므로 빈 문자열 또는 기본값
            createdAt: orderStatusEntity.createdAt,
            updatedAt: orderStatusEntity.createdAt // updatedAt이 없으므로 createdAt 사용
        )
    }

    // 🔥 주문 상태 변경 함수
    private func updateOrderStatus(orderCode: String, currentStatus: String, store: OrderHistoryStore) async {
        let nextStatus = getNextStatus(from: currentStatus)

        print("🔄 주문 상태 변경: \(currentStatus) → \(nextStatus)")

        do {
            let request = OrderChangeRequest(orderCode: orderCode, nextStatus: nextStatus)
            let response = try await NetworkManager.shared.fetch(
                OrderRouter.orderChange(request: request),
                successType: EmptyResponse.self,
                failureType: CommonMessageResponse.self
            )

            if response.success != nil {
                print("✅ 주문 상태 변경 성공: \(nextStatus)")

                await MainActor.run {
                    if nextStatus == "PICKED_UP" {
                        // 픽업 완료 시 과거 주문으로 이동 + 알림 발송
                        store.send(.orderCompleted(orderCode: orderCode))
                        sendPickupCompletedNotification(orderCode: orderCode, store: store)
                    } else {
                        // 일반 상태 업데이트
                        store.send(.orderStatusUpdated(orderCode: orderCode, newStatus: nextStatus))

                        // 픽업 준비 완료 시 알림 발송
                        if nextStatus == "READY_FOR_PICKUP" {
                            sendPickupReadyNotification(orderCode: orderCode, store: store)
                        }
                    }
                }
            } else if let error = response.failure {
                await MainActor.run {
                    store.send(.orderStatusUpdateFailed(orderCode: orderCode, error: error.message))
                }
            }
        } catch {
            await MainActor.run {
                store.send(.orderStatusUpdateFailed(orderCode: orderCode, error: error.localizedDescription))
            }
        }
    }

    // 🔥 알림 권한 요청
    private func requestNotificationPermission(store: OrderHistoryStore) async {
        let granted = await LocalNotificationManager.shared.requestPermission()
        await MainActor.run {
            store.send(.notificationPermissionUpdated(granted))
        }
    }

    // 🔥 픽업 준비 완료 알림
    private func sendPickupReadyNotification(orderCode: String, store: OrderHistoryStore) {
        // 해당 주문 정보 찾기
        let order = store.state.currentOrders.first { $0.orderCode == orderCode }
        let storeName = order?.store.name ?? "매장"

        LocalNotificationManager.shared.scheduleNotification(
            id: "\(orderCode)_pickup_ready",
            title: "픽업 준비가 완료되었습니다! ✨",
            body: "[\(storeName)]\n매장에서 픽업해주세요.",
            timeInterval: 1
        )
        print("🔔 픽업 준비 완료 알림 발송: \(orderCode)")
    }

    // 🔥 픽업 완료 알림
    private func sendPickupCompletedNotification(orderCode: String, store: OrderHistoryStore) {
        // 해당 주문 정보 찾기 (현재 주문 또는 과거 주문에서)
        let order = store.state.currentOrders.first { $0.orderCode == orderCode } ??
                   store.state.pastOrders.first { $0.orderCode == orderCode }
        let storeName = order?.store.name ?? "매장"

        LocalNotificationManager.shared.scheduleNotification(
            id: "\(orderCode)_pickup_completed",
            title: "픽업이 완료되었습니다! 🎉",
            body: "[\(storeName)]\n맛있게 드세요!",
            timeInterval: 1
        )
        print("🔔 픽업 완료 알림 발송: \(orderCode)")
    }

    // 🔥 다음 상태 결정 헬퍼 함수
    private func getNextStatus(from currentStatus: String) -> String {
        switch currentStatus {
        case "PENDING_APPROVAL":
            return "APPROVED"
        case "APPROVED":
            return "IN_PROGRESS"
        case "IN_PROGRESS":
            return "READY_FOR_PICKUP"
        case "READY_FOR_PICKUP":
            return "PICKED_UP"
        default:
            return currentStatus
        }
    }
}
