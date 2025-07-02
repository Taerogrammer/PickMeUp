//
//  CustomSearchBar.swift
//  PickMeUp
//
//  Created by 김태형 on 7/2/25.
//

import SwiftUI

struct CustomSearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.blackSprout)

            if text.isEmpty {
                Text("검색어를 입력해주세요.")
                    .foregroundColor(.gray60)
                    .font(.pretendardBody2)
            } else {
                TextField("", text: $text)
                    .font(.pretendardBody2)
                    .foregroundColor(.gray100)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.deepSprout, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
        )
    }
}
