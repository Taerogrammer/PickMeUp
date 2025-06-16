//
//  OrderSegmentedControlView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import SwiftUI

//TODO: - Binding 해결
struct OrderSegmentedControlView: View {
    @Binding var selectedOrderType: OrderType
    let currentOrdersCount: Int
    let pastOrdersCount: Int

    var body: some View {
        VStack(spacing: 0) {
            CustomSegmentedControl(
                preselectedIndex: Binding(
                    get: { OrderType.allCases.firstIndex(of: selectedOrderType) ?? 0 },
                    set: { selectedOrderType = OrderType.allCases[$0] }
                ),
                options: [
                    "\(OrderType.current.rawValue) (\(currentOrdersCount))",
                    "\(OrderType.past.rawValue) (\(pastOrdersCount))"
                ]
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // 구분선
            Rectangle()
                .fill(Color.gray15)
                .frame(height: 1)
        }
        .background(Color.white)
    }
}

struct OrderTabView: View {
    let store: OrderHistoryStore
    @Binding var selectedOrderType: OrderType
    let currentOrders: [OrderDataEntity]
    let pastOrders: [OrderDataEntity]

    var body: some View {
        TabView(selection: $selectedOrderType) {
            // 진행중인 주문
            CurrentOrderListView(store: store, orders: currentOrders) // Store 주입
                .tag(OrderType.current)

            // 과거 주문
            BeforeOrderListView(orders: pastOrders) // BeforeOrderListView도 수정 필요할 수 있음
                .tag(OrderType.past)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.3), value: selectedOrderType)
    }
}

//#Preview {
//    OrderSegmentedControlView()
//}
