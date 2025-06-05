//
//  StoreSummaryInfoView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/5/25.
//

import SwiftUI

struct StoreSummaryInfoView: View {
    let state: StoreDetailState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(state.name)
                    .font(.title2)
                    .bold()
                if state.isPickchelin {
                    Text("픽슐랭")
                        .font(.caption)
                        .padding(4)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(6)
                }
                Spacer()
                Image(systemName: "heart")
            }

            HStack(spacing: 8) {
                Label("\(state.likeCount)개", systemImage: "heart.fill")
                    .foregroundColor(.red)
                Label(String(format: "%.1f", state.rating), systemImage: "star.fill")
                    .foregroundColor(.yellow)
            }
            .font(.subheadline)
        }
        .padding(.horizontal)
    }
}

//#Preview {
//    StoreSummaryInfoView()
//}
