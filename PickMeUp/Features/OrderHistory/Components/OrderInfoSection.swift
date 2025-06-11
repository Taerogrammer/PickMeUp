//
//  OrderInfoSection.swift
//  PickMeUp
//
//  Created by 김태형 on 6/12/25.
//

import SwiftUI

struct OrderInfoSection: View {
    let orderData: OrderDataEntity

    var body: some View {
        VStack(spacing: 12) {
            OrderInfoRow(
                icon: "number.circle.fill",
                title: "주문번호",
                value: orderData.orderCode
            )

            Divider().background(Color.gray15)

            HStack {
                OrderInfoRow(
                    icon: "storefront.fill",
                    title: "매장명",
                    value: orderData.store.name
                )

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("주문시간")
                        .font(.pretendardCaption1)
                        .foregroundColor(.gray60)
                    Text(DateFormattingHelper.formatDate(orderData.createdAt))
                        .font(.pretendardCaption1)
                        .foregroundColor(.gray60)
                }
            }
        }
        .padding(20)
        .background(Color.gray15)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
