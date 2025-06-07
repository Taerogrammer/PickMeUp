//
//  StoreDetailInfoView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreDetailInfoView: View {
    let entity: StoreDetailInfoEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 8) {
                Text("가게주소")
                    .font(.caption)
                    .foregroundColor(.gray)
                Image(systemName: "location.fill")
                    .foregroundColor(.deepSprout)
                Text(entity.address)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }

            HStack(alignment: .top, spacing: 8) {
                Text("영업시간")
                    .font(.caption)
                    .foregroundColor(.gray)
                Image(systemName: "clock")
                    .foregroundColor(.deepSprout)
                Text("매일 \(entity.open) ~ \(entity.close)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }

            HStack(alignment: .top, spacing: 8) {
                Text("주차여부")
                    .font(.caption)
                    .foregroundColor(.gray)
                Image(systemName: "parkingsign.circle.fill")
                    .foregroundColor(.deepSprout)
                Text(entity.parkingGuide)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray0) // 배경색
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1) // 테두리
                )
        )
    }
}


#Preview {
    let mockEntity = StoreDetailInfoEntity(
        address: "서울시 강남구 도산대로 123",
        open: "10:00", close: "22:00",
        parkingGuide: "건물 지하 주차장 이용 가능"
    )

    StoreDetailInfoView(entity: mockEntity)
}
