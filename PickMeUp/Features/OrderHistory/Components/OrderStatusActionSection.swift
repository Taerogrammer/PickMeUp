//
//  OrderStatusActionSection.swift
//  PickMeUp
//
//  Created by 김태형 on 6/12/25.
//

import SwiftUI

struct OrderStatusActionSection: View {
    let orderData: OrderDataEntity
    @ObservedObject var store: OrderHistoryStore

    var body: some View {
        VStack(spacing: 16) {
            SectionHeader(icon: "arrow.clockwise.circle.fill", title: "주문 진행")

            Button(action: {
                store.send(.updateOrderStatus(
                    orderCode: orderData.orderCode,
                    currentStatus: orderData.orderStatus
                ))
            }) {
                HStack(spacing: 12) {
                    Image(systemName: OrderStatusHelper.getButtonIcon(orderData.orderStatus))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isPickupReady ? .white : .gray15)

                    Text(OrderStatusHelper.getButtonText(orderData.orderStatus))
                        .font(.pretendardBody1)
                        .fontWeight(.semibold)
                        .foregroundColor(isPickupReady ? .white : .gray15)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(buttonBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: isPickupReady ? Color.deepSprout.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
            }
        }
        .padding(20)
        .background(Color.gray15)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var isPickupReady: Bool {
        orderData.orderStatus == "READY_FOR_PICKUP"
    }

    private var buttonBackground: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isPickupReady ? [Color.deepSprout, Color.brightSprout] : [Color.gray60, Color.gray60]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

//#Preview {
//    OrderStatusActionSection()
//}
