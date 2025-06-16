//
//  OrderSegmentedControlView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import SwiftUI

struct OrderSegmentedControlView: View {
    let store: OrderHistoryStore
    let currentOrdersCount: Int
    let pastOrdersCount: Int

    var body: some View {
        VStack(spacing: 0) {
            CustomSegmentedControl(
                preselectedIndex: Binding(
                    get: { OrderType.allCases.firstIndex(of: store.state.selectedOrderType) ?? 0 },
                    set: { index in
                        let orderType = OrderType.allCases[index]
                        store.send(.selectOrderType(orderType))
                    }
                ),
                options: [
                    "\(OrderType.current.rawValue) (\(currentOrdersCount))",
                    "\(OrderType.past.rawValue) (\(pastOrdersCount))"
                ]
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Rectangle()
                .fill(Color.gray15)
                .frame(height: 1)
        }
        .background(Color.white)
    }
}

struct OrderTabView: View {
    let store: OrderHistoryStore
    let currentOrders: [OrderDataEntity]
    let pastOrders: [OrderDataEntity]

    var body: some View {
        TabView(selection: Binding(
            get: { store.state.selectedOrderType },
            set: { orderType in
                store.send(.selectOrderType(orderType))
            }
        )) {
            CurrentOrderListView(store: store, orders: currentOrders)
                .tag(OrderType.current)

            BeforeOrderListView(orders: pastOrders)
                .tag(OrderType.past)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.3), value: store.state.selectedOrderType)
    }
}

//#Preview {
//    OrderSegmentedControlView()
//}
