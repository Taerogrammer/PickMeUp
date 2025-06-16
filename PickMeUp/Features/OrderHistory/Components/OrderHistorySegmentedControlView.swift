//
//  OrderHistorySegmentedControlView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import SwiftUI

struct OrderHistorySegmentedControlView: View {
    let selectedOrderType: OrderType
    let currentOrdersCount: Int
    let pastOrdersCount: Int
    let onSelectionChanged: (OrderType) -> Void

    var body: some View {
        VStack(spacing: 0) {
            CustomSegmentedControl(
                preselectedIndex: Binding(
                    get: { OrderType.allCases.firstIndex(of: selectedOrderType) ?? 0 },
                    set: { onSelectionChanged(OrderType.allCases[$0]) }
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

//#Preview {
//    OrderHistorySegmentedControlView()
//}


struct OrderHistoryContentView: View {
    let store: OrderHistoryStore
    let selectedOrderType: OrderType
    let selectedOrders: [OrderDataEntity]
    let isLoading: Bool
    let isRefreshing: Bool
    let errorMessage: String?
    let onRefresh: () -> Void
    let pastOrders: [OrderDataEntity]

    var body: some View {
        if isLoading && selectedOrders.isEmpty {
            // 로딩 상태
            OrderHistoryLoadingView()
        } else if let errorMessage = errorMessage {
            // 에러 상태
            OrderHistoryErrorView(
                message: errorMessage,
                onRetry: onRefresh
            )
        } else if selectedOrders.isEmpty {
            // 빈 상태
            OrderEmptyStateView(type: selectedOrderType)
        } else {
            // 주문 리스트
            OrderHistoryListView(
                store: store,
                orders: selectedOrders,
                orderType: selectedOrderType,
                isRefreshing: isRefreshing,
                onRefresh: onRefresh
            )
        }
    }
}

struct OrderHistoryListView: View {
    let store: OrderHistoryStore
    let orders: [OrderDataEntity]
    let orderType: OrderType
    let isRefreshing: Bool
    let onRefresh: () -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(Array(orders.enumerated()), id: \.element.orderID) { index, order in
                    if orderType == .current {
                        OrderStatusView(store: store, orderData: order)
                    } else {
                        PastOrderCard(orderData: order)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .refreshable {
            onRefresh()
        }
    }
}

struct OrderHistoryLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)

            Text("주문 내역을 불러오는 중...")
                .font(.pretendardBody2)
                .foregroundColor(.gray60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray15.ignoresSafeArea())
    }
}

struct OrderHistoryErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text("오류가 발생했습니다")
                .font(.pretendardBody1)
                .foregroundColor(.gray75)

            Text(message)
                .font(.pretendardBody2)
                .foregroundColor(.gray60)
                .multilineTextAlignment(.center)

            Button("다시 시도") {
                onRetry()
            }
            .font(.pretendardBody1)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.deepSprout)
            .cornerRadius(8)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray15.ignoresSafeArea())
    }
}

struct OrderHistoryEmptyStateView: View {
    let orderType: OrderType

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: orderType == .current ? "clock" : "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray45)

            Text(orderType == .current ? "진행중인 주문이 없습니다" : "과거 주문 내역이 없습니다")
                .font(.pretendardBody1)
                .foregroundColor(.gray60)

            Text(orderType == .current ? "새로운 주문을 시작해보세요!" : "주문을 완료하면 여기에 표시됩니다")
                .font(.pretendardCaption1)
                .foregroundColor(.gray45)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray15.ignoresSafeArea())
    }
}

struct MockOrderData {
    static let currentOrders: [OrderData] = [
        // 여기에 기존 currentOrders 데이터 넣기
    ]

    static let pastOrders: [OrderData] = [
        // 여기에 기존 pastOrders 데이터 넣기
    ]
}
