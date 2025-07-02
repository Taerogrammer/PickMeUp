//
//  AddressResultRow.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import SwiftUI

struct AddressResultRowContent: View {
    let location: Location

    var body: some View {
        HStack(spacing: 16) {
            // 위치 아이콘
            ZStack {
                Circle()
                    .fill(Color.deepSprout.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.deepSprout)
            }

            VStack(alignment: .leading, spacing: 6) {
                // 주요 주소
                Text(location.address)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blackSprout)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                // 건물명
                if let name = location.name, !name.isEmpty {
                    Text(name)
                        .font(.system(size: 14))
                        .foregroundColor(.gray60)
                        .lineLimit(1)
                }

                // 좌표 정보
                Text("위도: \(String(format: "%.6f", location.latitude)), 경도: \(String(format: "%.6f", location.longitude))")
                    .font(.system(size: 12))
                    .foregroundColor(.gray45)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray45)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}
