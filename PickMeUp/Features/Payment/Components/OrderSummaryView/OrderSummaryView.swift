//
//  OrderSummaryView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/9/25.
//

import SwiftUI

struct OrderSummaryView: View {
    let paymentInfo: PaymentInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("주문 정보")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("주문 번호:")
                    Spacer()
                    Text(paymentInfo.orderCode)
                        .fontWeight(.medium)
                }

                HStack {
                    Text("매장:")
                    Spacer()
                    Text(paymentInfo.storeName)
                        .fontWeight(.medium)
                }
            }

            Divider()

            Text("주문 메뉴")
                .font(.headline)

            ForEach(paymentInfo.menuItems.indices, id: \.self) { index in
                let item = paymentInfo.menuItems[index]
                HStack {
                    Text(item.menu.name)
                    Spacer()
                    Text("\(item.quantity)개")
                    Text("\(item.totalPrice)원")
                        .fontWeight(.medium)
                }
            }

            Divider()

            HStack {
                Text("총 결제 금액")
                    .font(.headline)
                Spacer()
                Text("\(paymentInfo.totalPrice)원")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding()
    }
}

//#Preview {
//    OrderSummaryView()
//}
