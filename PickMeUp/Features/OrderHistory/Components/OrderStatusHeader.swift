//
//  OrderStatusHeader.swift
//  PickMeUp
//
//  Created by 김태형 on 6/12/25.
//

import SwiftUI

struct OrderStatusHeader: View {
    let orderData: OrderDataEntity

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("주문현황")
                    .font(.pretendardTitle1)
                    .foregroundColor(.white)
                    .fontWeight(.bold)

                Text("Order Status")
                    .font(.pretendardCaption1)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            OrderStatusBadge(status: orderData.orderStatus)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.deepSprout, Color.brightSprout]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}

//#Preview {
//    OrderStatusHeader()
//}
