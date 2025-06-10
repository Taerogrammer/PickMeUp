//
//  OrderEmptyStateView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/10/25.
//

import SwiftUI

struct OrderEmptyStateView: View {
    let type: OrderType

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: type == .current ? "clock" : "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray45)

            Text(type == .current ? "진행중인 주문이 없습니다" : "과거 주문 내역이 없습니다")
                .font(.pretendardBody1)
                .foregroundColor(.gray60)

            Text(type == .current ? "새로운 주문을 시작해보세요!" : "주문을 완료하면 여기에 표시됩니다")
                .font(.pretendardCaption1)
                .foregroundColor(.gray45)
        }
        .padding(.top, 100)
    }
}

//#Preview {
//    OrderEmptyStateView()
//}
