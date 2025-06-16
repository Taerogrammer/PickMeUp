//
//  OrderMenuSection.swift
//  PickMeUp
//
//  Created by 김태형 on 6/12/25.
//

import SwiftUI

struct OrderMenuSection: View {
    let store: OrderHistoryStore
    let orderData: OrderDataEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(icon: "menucard.fill", title: "주문 메뉴")

            VStack(spacing: 12) {
                ForEach(Array(orderData.orderMenuList.enumerated()), id: \.offset) { index, menuItem in
                    OrderMenuItemView(
                        store: store,
                        menuItem: menuItem,
                        orderCode: orderData.orderCode
                    )
                }
            }
        }
    }
}

//#Preview {
//    OrderMenuSection()
//}
