//
//  OrderHistoryEffect.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import SwiftUI

struct OrderHistoryEffect {
    func handle(_ action: OrderHistoryAction.Intent, store: OrderHistoryStore) {
        switch action {
        case .onAppear:
            Task {
                await loadInitialOrders(store: store)
                await requestNotificationPermission(store: store)
            }

        case .selectOrderType:
            break

        case .refresh:
            Task {
                await refreshAllOrders(store: store)
            }

        case .pullToRefresh:
            Task {
                await refreshAllOrders(store: store)
            }

        case .updateOrderStatus(let orderCode, let currentStatus):
            Task {
                await updateOrderStatus(orderCode: orderCode, currentStatus: currentStatus, store: store)
            }

        case .requestNotificationPermission:
            Task {
                await requestNotificationPermission(store: store)
            }

        case .loadMenuImage(let orderCode, let menuID, let imageUrl):
            loadMenuImage(orderCode: orderCode, menuID: menuID, imageUrl: imageUrl, store: store)
        }
    }

    // MARK: - Private Methods
    private func loadMenuImage(orderCode: String, menuID: String, imageUrl: String, store: OrderHistoryStore) {
        let responder = OrderMenuImageResponder(orderCode: orderCode, menuID: menuID, store: store)
        ImageLoader.load(from: imageUrl, responder: responder)
    }

    @MainActor
    private func loadInitialOrders(store: OrderHistoryStore) async {
        store.send(.ordersLoading)

        do {
            let response = try await NetworkManager.shared.fetch(
                OrderRouter.orderHistory,
                successType: OrderHistoryResponse.self,
                failureType: CommonMessageResponse.self
            )

            if let orderHistory = response.success {
                let allOrderEntities = orderHistory.toEntity()

                let currentOrders = allOrderEntities.filter { order in
                    let currentStatus = order.orderStatusTimeline.last { $0.completed }?.status ?? "PENDING_APPROVAL"
                    return ["PENDING_APPROVAL", "APPROVED", "IN_PROGRESS", "READY_FOR_PICKUP"].contains(currentStatus)
                }

                let pastOrders = allOrderEntities.filter { order in
                    let currentStatus = order.orderStatusTimeline.last { $0.completed }?.status ?? "PENDING_APPROVAL"
                    return currentStatus == "PICKED_UP"
                }

                let currentOrderDataEntities = currentOrders.map { convertToOrderDataEntity($0) }
                let pastOrderDataEntities = pastOrders.map { convertToOrderDataEntity($0) }

                store.send(.currentOrdersLoaded(currentOrderDataEntities))
                store.send(.pastOrdersLoaded(pastOrderDataEntities))

                loadAllMenuImages(orders: currentOrderDataEntities + pastOrderDataEntities, store: store)

                print("✅ [OrderHistoryEffect] 주문 내역 로드 성공 - 진행중: \(currentOrders.count)개, 과거: \(pastOrders.count)개")
            } else if let error = response.failure {
                store.send(.ordersLoadingFailed(error.message))
                print("❌ [OrderHistoryEffect] 주문 내역 로드 실패: \(error.message)")
            }
        } catch {
            store.send(.ordersLoadingFailed(error.localizedDescription))
            print("❌ [OrderHistoryEffect] 주문 내역 로드 에러: \(error.localizedDescription)")
        }
    }

    @MainActor private func loadAllMenuImages(orders: [OrderDataEntity], store: OrderHistoryStore) {
       for order in orders {
           for menuItem in order.orderMenuList {
               let imageUrl = menuItem.menu.menuImageUrl
               if !imageUrl.isEmpty {
                   store.send(.loadMenuImage(
                       orderCode: order.orderCode,
                       menuID: menuItem.menu.id,
                       imageUrl: imageUrl
                   ))
               }
           }
       }
    }

    @MainActor
    private func refreshAllOrders(store: OrderHistoryStore) async {
       do {
           let response = try await NetworkManager.shared.fetch(
               OrderRouter.orderHistory,
               successType: OrderHistoryResponse.self,
               failureType: CommonMessageResponse.self
           )

           if let orderHistory = response.success {
               let allOrderEntities = orderHistory.toEntity()

               let currentOrders = allOrderEntities.filter { order in
                   let currentStatus = order.orderStatusTimeline.last { $0.completed }?.status ?? "PENDING_APPROVAL"
                   return ["PENDING_APPROVAL", "APPROVED", "IN_PROGRESS", "READY_FOR_PICKUP"].contains(currentStatus)
               }

               let pastOrders = allOrderEntities.filter { order in
                   let currentStatus = order.orderStatusTimeline.last { $0.completed }?.status ?? "PENDING_APPROVAL"
                   return currentStatus == "PICKED_UP"
               }

               let currentOrderDataEntities = currentOrders.map { convertToOrderDataEntity($0) }
               let pastOrderDataEntities = pastOrders.map { convertToOrderDataEntity($0) }

               store.send(.currentOrdersLoaded(currentOrderDataEntities))
               store.send(.pastOrdersLoaded(pastOrderDataEntities))
               store.send(.refreshCompleted)

               loadAllMenuImages(orders: currentOrderDataEntities + pastOrderDataEntities, store: store)

               print("✅ [OrderHistoryEffect] 주문 내역 새로고침 성공 - 진행중: \(currentOrders.count)개, 과거: \(pastOrders.count)개")
           } else if let error = response.failure {
               store.send(.ordersLoadingFailed(error.message))
               store.send(.refreshCompleted)
               print("❌ [OrderHistoryEffect] 주문 내역 새로고침 실패: \(error.message)")
           }
       } catch {
           store.send(.ordersLoadingFailed(error.localizedDescription))
           store.send(.refreshCompleted)
           print("❌ [OrderHistoryEffect] 주문 내역 새로고침 에러: \(error.localizedDescription)")
       }
    }

    private func convertToOrderDataEntity(_ orderStatusEntity: OrderStatusEntity) -> OrderDataEntity {
        let currentStatus = orderStatusEntity.orderStatusTimeline.last { $0.completed }?.status ?? "PENDING_APPROVAL"

        return OrderDataEntity(
            orderID: orderStatusEntity.orderID,
            orderCode: orderStatusEntity.orderCode,
            totalPrice: orderStatusEntity.totalPrice,
            review: nil,
            store: orderStatusEntity.store,
            orderMenuList: orderStatusEntity.orderMenuList,
            orderStatus: currentStatus,
            orderStatusTimeline: orderStatusEntity.orderStatusTimeline,
            paidAt: "",
            createdAt: orderStatusEntity.createdAt,
            updatedAt: orderStatusEntity.createdAt
        )
    }

    @MainActor
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

               if nextStatus == "PICKED_UP" {
                   store.send(.orderCompleted(orderCode: orderCode))
                   sendPickupCompletedNotification(orderCode: orderCode, store: store)
               } else {
                   store.send(.orderStatusUpdated(orderCode: orderCode, newStatus: nextStatus))

                   if nextStatus == "READY_FOR_PICKUP" {
                       sendPickupReadyNotification(orderCode: orderCode, store: store)
                   }
               }
           } else if let error = response.failure {
               store.send(.orderStatusUpdateFailed(orderCode: orderCode, error: error.message))
           }
       } catch {
           store.send(.orderStatusUpdateFailed(orderCode: orderCode, error: error.localizedDescription))
       }
    }

    @MainActor
    private func requestNotificationPermission(store: OrderHistoryStore) async {
       let granted = await LocalNotificationManager.shared.requestPermission()
       store.send(.notificationPermissionUpdated(granted))
    }

    private func sendPickupReadyNotification(orderCode: String, store: OrderHistoryStore) {
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

    private func sendPickupCompletedNotification(orderCode: String, store: OrderHistoryStore) {
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

    private func getNextStatus(from currentStatus: String) -> String {
        switch currentStatus {
        case "PENDING_APPROVAL": return "APPROVED"
        case "APPROVED": return "IN_PROGRESS"
        case "IN_PROGRESS": return "READY_FOR_PICKUP"
        case "READY_FOR_PICKUP": return "PICKED_UP"
        default: return currentStatus
        }
    }
}

final class OrderMenuImageResponder: @preconcurrency ImageLoadRespondable {
    private let orderCode: String
    private let menuID: String
    private let store: OrderHistoryStore

    init(orderCode: String, menuID: String, store: OrderHistoryStore) {
        self.orderCode = orderCode
        self.menuID = menuID
        self.store = store
    }

    @MainActor func onImageLoaded(_ image: UIImage) {
        store.send(.menuImageLoaded(orderCode: orderCode, menuID: menuID, image: image))
    }

    @MainActor func onImageLoadFailed(_ errorMessage: String) {
        store.send(.menuImageLoadFailed(orderCode: orderCode, menuID: menuID, error: errorMessage))
    }
}
