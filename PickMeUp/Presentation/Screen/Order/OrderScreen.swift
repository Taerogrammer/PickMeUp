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
    let store: OrderHistoryStore

    init(store: OrderHistoryStore) {
        self.store = store
    }

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
                store: store,
                onRefresh: {
                    store.send(.pullToRefresh)
                },
                pastOrders: store.state.pastOrders
            )
        }
        .background(Color.gray15.ignoresSafeArea())
        .onAppear {
            store.send(.viewOnAppear)
        }
    }
}


//#Preview {
//    OrderScreen()
//}
