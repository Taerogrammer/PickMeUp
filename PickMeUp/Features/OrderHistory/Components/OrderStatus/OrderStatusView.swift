//
//  OrderStatusView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import SwiftUI

struct OrderStatusView: View {
    let orderData: OrderDataEntity
    @ObservedObject var store: OrderHistoryStore

    var body: some View {
        if orderData.orderStatus == "PICKED_UP" {
            EmptyView()
        } else {
            OrderStatusCard(orderData: orderData, store: store)
        }
    }
}

// MARK: - OrderStatusCard
struct OrderStatusCard: View {
    let orderData: OrderDataEntity
    @ObservedObject var store: OrderHistoryStore

    var body: some View {
        VStack(spacing: 0) {
            OrderStatusHeader(orderData: orderData)

            VStack(spacing: 28) {
                OrderInfoSection(orderData: orderData)
                OrderTimelineSection(orderData: orderData)

                if OrderStatusHelper.shouldShowActionButton(for: orderData.orderStatus) {
                    OrderStatusActionSection(orderData: orderData, store: store)
                }

                OrderMenuSection(orderData: orderData, store: store) // 🔥 store 전달
                OrderPaymentSection(orderData: orderData)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}


// MARK: - Preview
struct OrderStatusView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                OrderStatusView(orderData: sampleOrderData,
                                store: OrderHistoryStore())
                OrderStatusView(orderData: sampleOrderData2,
                                store: OrderHistoryStore())
                OrderStatusView(orderData: sampleOrderData3,
                                store: OrderHistoryStore())
            }
            .padding()
        }
        .background(Color.gray15)
    }

    static let sampleOrderData = OrderDataEntity(
        orderID: "sample_id",
        orderCode: "A4922",
        totalPrice: 17200,
        review: nil,
        store: StoreEntity(
            id: "store_id",
            category: "카페",
            name: "새싹 도넛 가게",
            close: "22:00",
            storeImageUrls: [],
            hashTags: [],
            geolocation: GeolocationEntity(longitude: 0, latitude: 0),
            createdAt: "",
            updatedAt: ""
        ),
        orderMenuList: [
            OrderMenuEntity(
                menu: MenuInfoEntity(
                    id: "menu1",
                    name: "올리브 그린 새싹 도넛",
                    price: 1600,
                    menuImageUrl: ""
                ),
                quantity: 2
            )
        ],
        orderStatus: "READY_FOR_PICKUP",
        orderStatusTimeline: [
            OrderStatusTimelineEntity(status: "PENDING_APPROVAL", completed: true, changedAt: "2024-01-22T18:24:00.000Z"),
            OrderStatusTimelineEntity(status: "APPROVED", completed: true, changedAt: "2024-01-22T18:27:00.000Z"),
            OrderStatusTimelineEntity(status: "IN_PROGRESS", completed: true, changedAt: "2024-01-22T18:36:00.000Z"),
            OrderStatusTimelineEntity(status: "READY_FOR_PICKUP", completed: true, changedAt: nil),
            OrderStatusTimelineEntity(status: "PICKED_UP", completed: false, changedAt: nil)
        ],
        paidAt: "",
        createdAt: "2024-01-22T17:20:00.000Z",
        updatedAt: ""
    )

    static let sampleOrderData2 = OrderDataEntity(
        orderID: "sample_id_2",
        orderCode: "B5831",
        totalPrice: 8500,
        review: nil,
        store: StoreEntity(
            id: "store_id_2",
            category: "피자",
            name: "새싹 피자 홍대점",
            close: "22:00",
            storeImageUrls: [],
            hashTags: [],
            geolocation: GeolocationEntity(longitude: 0, latitude: 0),
            createdAt: "",
            updatedAt: ""
        ),
        orderMenuList: [
            OrderMenuEntity(
                menu: MenuInfoEntity(
                    id: "menu2",
                    name: "새싹 특제 피자",
                    price: 8500,
                    menuImageUrl: ""
                ),
                quantity: 1
            )
        ],
        orderStatus: "PICKED_UP",
        orderStatusTimeline: [
            OrderStatusTimelineEntity(status: "PENDING_APPROVAL", completed: true, changedAt: "2024-01-21T15:10:00.000Z"),
            OrderStatusTimelineEntity(status: "APPROVED", completed: true, changedAt: "2024-01-21T15:12:00.000Z"),
            OrderStatusTimelineEntity(status: "IN_PROGRESS", completed: true, changedAt: "2024-01-21T15:25:00.000Z"),
            OrderStatusTimelineEntity(status: "READY_FOR_PICKUP", completed: true, changedAt: "2024-01-21T15:40:00.000Z"),
            OrderStatusTimelineEntity(status: "PICKED_UP", completed: true, changedAt: "2024-01-21T15:45:00.000Z")
        ],
        paidAt: "",
        createdAt: "2024-01-21T15:08:00.000Z",
        updatedAt: ""
    )

    static let sampleOrderData3 = OrderDataEntity(
        orderID: "sample_id",
        orderCode: "A4922",
        totalPrice: 17200,
        review: nil,
        store: StoreEntity(
            id: "store_id",
            category: "카페",
            name: "새싹 도넛 가게",
            close: "22:00",
            storeImageUrls: [],
            hashTags: [],
            geolocation: GeolocationEntity(longitude: 0, latitude: 0),
            createdAt: "",
            updatedAt: ""
        ),
        orderMenuList: [
            OrderMenuEntity(
                menu: MenuInfoEntity(
                    id: "menu1",
                    name: "올리브 그린 새싹 도넛",
                    price: 1600,
                    menuImageUrl: ""
                ),
                quantity: 2
            )
        ],
        orderStatus: "IN_PROGRESS",
        orderStatusTimeline: [
            OrderStatusTimelineEntity(status: "PENDING_APPROVAL", completed: true, changedAt: "2024-01-22T18:24:00.000Z"),
            OrderStatusTimelineEntity(status: "APPROVED", completed: true, changedAt: "2024-01-22T18:27:00.000Z"),
            OrderStatusTimelineEntity(status: "IN_PROGRESS", completed: true, changedAt: "2024-01-22T18:36:00.000Z"),
            OrderStatusTimelineEntity(status: "READY_FOR_PICKUP", completed: false, changedAt: nil),
            OrderStatusTimelineEntity(status: "PICKED_UP", completed: false, changedAt: nil)
        ],
        paidAt: "",
        createdAt: "2024-01-22T17:20:00.000Z",
        updatedAt: ""
    )
}
