//
//  OrderMenuSection.swift
//  PickMeUp
//
//  Created by 김태형 on 6/12/25.
//

import SwiftUI

struct OrderMenuSection: View {
    let orderData: OrderDataEntity
    @ObservedObject var store: OrderHistoryStore // 🔥 Store 추가

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(icon: "menucard.fill", title: "주문 메뉴")

            VStack(spacing: 12) {
                ForEach(Array(orderData.orderMenuList.enumerated()), id: \.offset) { index, menuItem in
                    OrderMenuItemView(
                        menuItem: menuItem,
                        orderCode: orderData.orderCode, // 🔥 orderCode 전달
                        store: store // 🔥 store 전달
                    )
                }
            }
        }
    }
}

//#Preview {
//    OrderMenuSection()
//}
