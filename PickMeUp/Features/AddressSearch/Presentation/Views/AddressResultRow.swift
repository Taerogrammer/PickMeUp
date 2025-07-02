//
//  AddressResultRow.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import SwiftUI

// MARK: - 검색 결과 행
struct AddressResultRow: View {
    let location: Location
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
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
                    // 주요 주소 (도로명 주소 우선)
                    Text(location.address)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blackSprout)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)

                    // 부가 정보 (건물명이 있다면 표시)
                    if let name = location.name, !name.isEmpty {
                        Text(name)
                            .font(.system(size: 14))
                            .foregroundColor(.gray60)
                            .lineLimit(1)
                    }

                    // 좌표 정보 (작은 글씨로)
                    Text("위도: \(String(format: "%.6f", location.latitude)), 경도: \(String(format: "%.6f", location.longitude))")
                        .font(.system(size: 12))
                        .foregroundColor(.gray45)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray45)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
