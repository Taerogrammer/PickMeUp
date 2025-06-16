//
//  StoreSearchHeaderView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/3/25.
//

import SwiftUI

// TODO: - 구현 예정
struct StoreSearchHeaderView: View {
    @State private var searchText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LocationRow()
            CustomSearchBar(text: $searchText)
            PopularKeywordRow()
        }
        .padding()
        .background(Color.brightSprout)
    }
}

private struct LocationRow: View {
    var body: some View {
        HStack(spacing: 8) {
            Image("annotation")
                .scaledToFit()
                .frame(width: 24, height: 24)

            Text("문래역, 영등포구")
                .font(.pretendardBody1)
                .foregroundColor(.gray90)

            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 8))

            Spacer()
        }
        .foregroundColor(.gray90)
    }
}

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


private struct PopularKeywordRow: View {
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 2) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundColor(.deepSprout)
                Text("인기검색어")
                    .font(.pretendardCaption1)
                    .foregroundColor(.deepSprout)
            }
            Text("1 스타벅스")
                .font(.pretendardCaption1)
                .foregroundColor(.blackSprout)
            Spacer()
        }
    }
}

#Preview {
    StoreSearchHeaderView()
}
