//
//  CurrentOrderListView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import SwiftUI

struct CurrentOrderListView: View {
    let store: OrderHistoryStore
    let orders: [OrderDataEntity]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if orders.isEmpty {
                    OrderEmptyStateView(type: .current)
                } else {
                    ForEach(Array(orders.enumerated()), id: \.element.orderID) { index, order in
                        OrderStatusView(store: store, orderData: order)
                            .id("current_\(index)")
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0.8)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.98)
                            }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
    }
}



//#Preview {
//    CurrentOrderListView()
//}
