//
//  PopularKeywordRow.swift
//  PickMeUp
//
//  Created by 김태형 on 6/26/25.
//

import SwiftUI

// MARK: - Popular Keywords
struct PopularKeywordRow: View {
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
