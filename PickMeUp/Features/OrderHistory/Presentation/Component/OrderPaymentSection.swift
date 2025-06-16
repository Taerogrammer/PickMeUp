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
       VStack(alignment: .leading, spacing: 12) {
           HStack {
               SectionHeader(icon: "creditcard.fill", title: "결제 정보")

               Spacer()

               Text("총 \(orderData.orderMenuList.count)개")
                   .font(.pretendardCaption1)
                   .foregroundColor(.gray60)
           }

           VStack(spacing: 8) {
               HStack {
                   Text("총 결제금액")
                       .font(.pretendardCaption1)
                       .foregroundColor(.gray60)

                   Spacer()

                   Text("₩\(orderData.totalPrice.formatted())")
                       .font(.pretendardBody2)
                       .fontWeight(.semibold)
                       .foregroundColor(.gray90)
               }

               HStack {
                   Text("결제일시")
                       .font(.pretendardCaption2)
                       .foregroundColor(.gray60)

                   Spacer()

                   Text(DateFormattingHelper.formatDate(orderData.paidAt))
                       .font(.pretendardCaption2)
                       .foregroundColor(.gray75)
               }
           }
           .padding(16)
           .background(Color.gray15)
           .clipShape(RoundedRectangle(cornerRadius: 12))
       }
   }
}

//#Preview {
//    OrderPaymentSection()
//}
