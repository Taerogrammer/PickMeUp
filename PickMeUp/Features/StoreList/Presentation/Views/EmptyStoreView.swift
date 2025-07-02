//
//  EmptyStoreView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/30/25.
//

import SwiftUI

// ✅ 빈 상태 뷰 분리
struct EmptyStoreView: View {
    var body: some View {
        Text("불러올 가게가 없습니다.")
            .foregroundColor(.gray60)
            .font(.caption)
            .padding(.vertical, 32)
            .frame(maxWidth: .infinity)
    }
}
