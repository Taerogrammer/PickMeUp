//
//  StoreEstimatedTimeView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreEstimatedTimeView: View {
    let entity: StoreEstimatedTimeEntity

    var body: some View {
        HStack {
            Label(
                "예상 소요시간 \(entity.estimatedPickupTime)분",
                systemImage: "figure.run"
            )
            .font(.footnote)
            .foregroundColor(.deepSprout)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.deepSprout.opacity(0.3), lineWidth: 1)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let mockEntity = StoreEstimatedTimeEntity(
        estimatedPickupTime: 30,
        distance: "3.2km"
    )

    return StoreEstimatedTimeView(entity: mockEntity)
}
