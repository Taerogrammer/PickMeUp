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
    @StateObject private var store = OrderHistoryStore()

    var body: some View {
        VStack(spacing: 0) {
            // 세그먼트 컨트롤
            OrderHistorySegmentedControlView(
                selectedOrderType: store.state.selectedOrderType,
                currentOrdersCount: store.state.currentOrdersCount,
                pastOrdersCount: store.state.pastOrdersCount,
                onSelectionChanged: { orderType in
                    store.send(.selectOrderType(orderType))
                }
            )

            // 주문 리스트
            OrderHistoryContentView(
                selectedOrderType: store.state.selectedOrderType,
                selectedOrders: store.state.selectedOrders,
                isLoading: store.state.isLoading,
                isRefreshing: store.state.isRefreshing,
                errorMessage: store.state.errorMessage,
                onRefresh: {
                    store.send(.pullToRefresh)
                }
            )
        }
        .background(Color.gray15.ignoresSafeArea())
        .navigationTitle("주문 내역")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            store.send(.viewOnAppear)
        }
    }
}


#Preview {
    OrderScreen()
}
