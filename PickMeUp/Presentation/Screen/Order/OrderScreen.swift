//
//  OrderScreen.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import SwiftUI

enum OrderType: String, CaseIterable {
    case current = "진행중"
    case past = "과거주문"
}

struct OrderScreen: View {
    @State private var selectedOrderType: OrderType = .current
    @State private var currentOrders: [OrderData] = []
    @State private var pastOrders: [OrderData] = []

    var body: some View {
        VStack(spacing: 0) {
            OrderSegmentedControlView(
                selectedOrderType: $selectedOrderType,
                currentOrdersCount: currentOrders.count,
                pastOrdersCount: pastOrders.count
            )

            OrderTabView(
                selectedOrderType: $selectedOrderType,
                currentOrders: currentOrders,
                pastOrders: pastOrders
            )
        }
        .background(Color.gray15.ignoresSafeArea())
        .navigationTitle("주문 내역")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadSampleOrders()
        }
    }

    // MARK: - Load Sample Data
    private func loadSampleOrders() {
        // 진행중인 주문 (PENDING_APPROVAL, APPROVED, IN_PROGRESS, READY_FOR_PICKUP)
        currentOrders = [
            OrderData(
                orderID: "current_1",
                orderCode: "A4922",
                totalPrice: 17200,
                review: nil,
                store: Store(
                    id: "store_1",
                    category: "카페",
                    name: "새싹 도넛 가게",
                    close: "22:00",
                    storeImageUrls: [],
                    hashTags: [],
                    geolocation: Geolocation(longitude: 0, latitude: 0),
                    createdAt: "",
                    updatedAt: ""
                ),
                orderMenuList: [
                    OrderMenu(
                        menu: MenuInfo(
                            id: "menu1",
                            category: "도넛",
                            name: "올리브 그린 새싹 도넛",
                            description: "",
                            originInformation: "",
                            price: 1600,
                            tags: [],
                            menuImageUrl: "",
                            createdAt: "",
                            updatedAt: ""
                        ),
                        quantity: 2
                    ),
                    OrderMenu(
                        menu: MenuInfo(
                            id: "menu2",
                            category: "ㅇㅇㅇㅇ",
                            name: "올리브 케이크",
                            description: "",
                            originInformation: "",
                            price: 15800,
                            tags: [],
                            menuImageUrl: "",
                            createdAt: "",
                            updatedAt: ""
                        ),
                        quantity: 2
                    )
                ],
                currentOrderStatus: "IN_PROGRESS",
                orderStatusTimeline: [
                    OrderStatusTimeline(status: "PENDING_APPROVAL", completed: true, changedAt: "2024-01-22T18:24:00.000Z"),
                    OrderStatusTimeline(status: "APPROVED", completed: true, changedAt: "2024-01-22T18:27:00.000Z"),
                    OrderStatusTimeline(status: "IN_PROGRESS", completed: true, changedAt: "2024-01-22T18:36:00.000Z"),
                    OrderStatusTimeline(status: "READY_FOR_PICKUP", completed: false, changedAt: nil),
                    OrderStatusTimeline(status: "PICKED_UP", completed: false, changedAt: nil)
                ],
                paidAt: "",
                createdAt: "2024-01-22T17:20:00.000Z",
                updatedAt: ""
            ),

            OrderData(
                orderID: "current_2",
                orderCode: "C7264",
                totalPrice: 12000,
                review: nil,
                store: Store(
                    id: "store_3",
                    category: "커피",
                    name: "새싹 커피 홍대점",
                    close: "21:00",
                    storeImageUrls: [],
                    hashTags: [],
                    geolocation: Geolocation(longitude: 0, latitude: 0),
                    createdAt: "",
                    updatedAt: ""
                ),
                orderMenuList: [
                    OrderMenu(
                        menu: MenuInfo(
                            id: "menu4",
                            category: "커피",
                            name: "새싹 아메리카노",
                            description: "",
                            originInformation: "",
                            price: 4000,
                            tags: [],
                            menuImageUrl: "",
                            createdAt: "",
                            updatedAt: ""
                        ),
                        quantity: 2
                    )
                ],
                currentOrderStatus: "READY_FOR_PICKUP",
                orderStatusTimeline: [
                    OrderStatusTimeline(status: "PENDING_APPROVAL", completed: true, changedAt: "2024-01-23T09:15:00.000Z"),
                    OrderStatusTimeline(status: "APPROVED", completed: true, changedAt: "2024-01-23T09:17:00.000Z"),
                    OrderStatusTimeline(status: "IN_PROGRESS", completed: true, changedAt: "2024-01-23T09:25:00.000Z"),
                    OrderStatusTimeline(status: "READY_FOR_PICKUP", completed: true, changedAt: "2024-01-23T09:30:00.000Z"),
                    OrderStatusTimeline(status: "PICKED_UP", completed: false, changedAt: nil)
                ],
                paidAt: "",
                createdAt: "2024-01-23T09:13:00.000Z",
                updatedAt: ""
            )
        ]

        // 과거 주문 (PICKED_UP)
        pastOrders = [
            OrderData(
                orderID: "past_1",
                orderCode: "B5831",
                totalPrice: 8500,
                review: Review(id: "review_1", rating: 5),
                store: Store(
                    id: "store_2",
                    category: "패스트푸드",
                    name: "새싹 피자 창동점",
                    close: "22:00",
                    storeImageUrls: [],
                    hashTags: [],
                    geolocation: Geolocation(longitude: 0, latitude: 0),
                    createdAt: "",
                    updatedAt: ""
                ),
                orderMenuList: [
                    OrderMenu(
                        menu: MenuInfo(
                            id: "menu3",
                            category: "피자",
                            name: "새싹 특제 피자",
                            description: "",
                            originInformation: "",
                            price: 8500,
                            tags: [],
                            menuImageUrl: "",
                            createdAt: "",
                            updatedAt: ""
                        ),
                        quantity: 1
                    )
                ],
                currentOrderStatus: "PICKED_UP",
                orderStatusTimeline: [
                    OrderStatusTimeline(status: "PENDING_APPROVAL", completed: true, changedAt: "2024-01-20T15:10:00.000Z"),
                    OrderStatusTimeline(status: "APPROVED", completed: true, changedAt: "2024-01-20T15:12:00.000Z"),
                    OrderStatusTimeline(status: "IN_PROGRESS", completed: true, changedAt: "2024-01-20T15:25:00.000Z"),
                    OrderStatusTimeline(status: "READY_FOR_PICKUP", completed: true, changedAt: "2024-01-20T15:40:00.000Z"),
                    OrderStatusTimeline(status: "PICKED_UP", completed: true, changedAt: "2024-01-20T15:45:00.000Z")
                ],
                paidAt: "",
                createdAt: "2024-01-20T15:08:00.000Z",
                updatedAt: ""
            ),

            OrderData(
                orderID: "past_2",
                orderCode: "D9876",
                totalPrice: 15300,
                review: nil,
                store: Store(
                    id: "store_4",
                    category: "한식",
                    name: "새싹 김밥천국",
                    close: "23:00",
                    storeImageUrls: [],
                    hashTags: [],
                    geolocation: Geolocation(longitude: 0, latitude: 0),
                    createdAt: "",
                    updatedAt: ""
                ),
                orderMenuList: [
                    OrderMenu(
                        menu: MenuInfo(
                            id: "menu6",
                            category: "김밥",
                            name: "새싹 참치김밥",
                            description: "",
                            originInformation: "",
                            price: 3600,
                            tags: [],
                            menuImageUrl: "",
                            createdAt: "",
                            updatedAt: ""
                        ),
                        quantity: 2
                    ),
                    OrderMenu(
                        menu: MenuInfo(
                            id: "menu7",
                            category: "라면",
                            name: "새싹 라면",
                            description: "",
                            originInformation: "",
                            price: 4050,
                            tags: [],
                            menuImageUrl: "",
                            createdAt: "",
                            updatedAt: ""
                        ),
                        quantity: 2
                    )
                ],
                currentOrderStatus: "PICKED_UP",
                orderStatusTimeline: [
                    OrderStatusTimeline(status: "PENDING_APPROVAL", completed: true, changedAt: "2024-01-19T12:10:00.000Z"),
                    OrderStatusTimeline(status: "APPROVED", completed: true, changedAt: "2024-01-19T12:12:00.000Z"),
                    OrderStatusTimeline(status: "IN_PROGRESS", completed: true, changedAt: "2024-01-19T12:20:00.000Z"),
                    OrderStatusTimeline(status: "READY_FOR_PICKUP", completed: true, changedAt: "2024-01-19T12:25:00.000Z"),
                    OrderStatusTimeline(status: "PICKED_UP", completed: true, changedAt: "2024-01-19T12:28:00.000Z")
                ],
                paidAt: "",
                createdAt: "2024-01-19T12:08:00.000Z",
                updatedAt: ""
            )
        ]
    }
}

#Preview {
    OrderScreen()
}
