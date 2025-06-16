//
//  StoreSummaryInfoView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreSummaryInfoView: View {
    let entity: StoreSummaryInfoEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(entity.name)
                    .font(.pretendardTitle1)
                    .bold()
                if entity.isPickchelin {
                    PickchelinConcaveRibbonView()
                }
                Spacer()
            }

            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.brightForsythia)
                    Text("\(entity.pickCount)")
                        .font(.pretendardBody1)
                }
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.brightForsythia)
                    Text(String(format: "%.1f", entity.totalRating))
                        .font(.pretendardBody1)
                }
                Text("(\(entity.totalReviewCount))")
                    .font(.pretendardBody1)
                    .foregroundColor(.gray60)

                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "motorcycle")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.gray45)
                    Text("누적 주문 \(entity.totalOrderCount)회")
                        .font(.pretendardBody3)
                        .foregroundColor(.gray45)
                }
            }
        }
    }
}

#Preview {
    let mockEntity = StoreSummaryInfoEntity(
        name: "도넛왕",
        isPickchelin: true,
        pickCount: 128,
        totalRating: 4.7,
        totalReviewCount: 211,
        totalOrderCount: 135
    )

    return StoreSummaryInfoView(entity: mockEntity)
}
