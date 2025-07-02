//
//  LoadginAndEndView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/30/25.
//

import SwiftUI

// ✅ 로딩 및 종료 뷰 분리
struct LoadingAndEndViews: View {
    @ObservedObject var store: StoreListStore

    var body: some View {
        if store.state.isLoadingMore {
            HStack {
                ProgressView()
                    .scaleEffect(0.8)
                Text("더 많은 가게를 불러오는 중...")
                    .font(.caption)
                    .foregroundColor(.gray60)
            }
            .padding(.vertical, 16)
        }

        if store.state.hasReachedEnd && !store.state.stores.isEmpty {
            Text("모든 가게를 불러왔습니다.")
                .font(.caption)
                .foregroundColor(.gray60)
                .padding(.vertical, 16)
        }
    }
}
