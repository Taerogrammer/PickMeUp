//
//  OrderStatusBadge.swift
//  PickMeUp
//
//  Created by 김태형 on 6/12/25.
//

import SwiftUI

struct OrderStatusBadge: View {
    let status: String

    var body: some View {
        Text(OrderStatusHelper.getDisplayName(status))
            .font(.pretendardCaption1)
            .fontWeight(.semibold)
            .foregroundColor(.deepSprout)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

//#Preview {
//    OrderStatusBadge()
//}
