//
//  OrderPaymentSection.swift
//  PickMeUp
//
//  Created by 김태형 on 6/12/25.
//

import SwiftUI

struct OrderPaymentSection: View {
    let orderData: OrderDataEntity

    var body: some View {
        VStack(spacing: 12) {
            SectionHeader(icon: "creditcard.fill", title: "결제 정보")

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("총 \(OrderCalculationHelper.getTotalQuantity(from: orderData))개 상품")
                        .font(.pretendardBody2)
                        .foregroundColor(.gray60)
                    Text("결제완료")
                        .font(.pretendardCaption1)
                        .foregroundColor(.deepSprout)
                        .fontWeight(.medium)
                }

                Spacer()

                Text("\(orderData.totalPrice.formattedPrice)원")
                    .font(.pretendardTitle1)
                    .fontWeight(.bold)
                    .foregroundColor(.gray90)
            }
            .padding(20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.brightSprout.opacity(0.1), Color.deepSprout.opacity(0.05)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

//#Preview {
//    OrderPaymentSection()
//}
