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
            HStack {
                Text(entity.name)
                    .font(.title2)
                    .bold()
                if entity.isPickchelin {
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
                Label("\(entity.pickCount)", systemImage: "heart.fill")
                    .foregroundColor(.red)
                Label(String(format: "%.1f", entity.rating), systemImage: "star.fill")
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
