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
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "number.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.deepSprout)
                    Text("주문번호")
                        .font(.pretendardCaption1)
                        .foregroundColor(.gray60)
                }

                Spacer()

                Text(orderData.orderCode)
                    .font(.pretendardCaption1)
                    .fontWeight(.medium)
                    .foregroundColor(.gray90)
            }

            Divider().background(Color.gray15)

            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "storefront.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.deepSprout)
                    Text(orderData.store.name)
                        .font(.pretendardCaption1)
                        .fontWeight(.medium)
                        .foregroundColor(.gray90)
                }

                Spacer()

                Text(DateFormattingHelper.formatDate(orderData.createdAt))
                    .font(.pretendardCaption2)
                    .foregroundColor(.gray60)
            }
        }
        .padding(16)
        .background(Color.gray15)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
