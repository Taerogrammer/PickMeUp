//
//  StoreListItemView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/2/25.
//

import SwiftUI

struct StoreListItemView: View {
    let store: StorePresentable

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: store.storeImageURLs.first ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Color.gray30
                    }
                }
                .frame(height: 160)
                .clipped()
                .cornerRadius(12)

                HStack {
                    Image(systemName: store.isPick ? "heart.fill" : "heart")
                        .foregroundColor(store.isPick ? .deepSprout : .gray60)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)

                    Spacer()

                    if store.isPicchelin {
                        Text("픽슐랭")
                            .font(.pretendardBody2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.deepSprout)
                            .cornerRadius(8)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .top)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(store.name)
                        .font(.pretendardBody1)
                        .foregroundColor(.gray100)
                    Spacer()
                    Image(systemName: "heart.fill")
                        .foregroundColor(.brightForsythia)
                    Text("\(store.pickCount)")
                        .font(.pretendardCaption1)
                        .foregroundColor(.gray75)
                }

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.brightForsythia)
                    Text(String(format: "%.1f", store.totalRating))
                        .font(.pretendardCaption1)
                        .foregroundColor(.gray100)
                    Text("(\(store.totalReviewCount))")
                        .font(.pretendardCaption1)
                        .foregroundColor(.gray60)
                }

                HStack(spacing: 16) {
                    Label("\(formattedDistance)", systemImage: "paperplane")
                        .font(.pretendardCaption1)
                        .foregroundColor(.gray60)
                    Label(store.close, systemImage: "clock")
                        .font(.pretendardCaption1)
                        .foregroundColor(.gray60)
                    Label("\(store.totalOrderCount)회", systemImage: "figure.walk")
                        .font(.pretendardCaption1)
                        .foregroundColor(.gray60)
                }

                HStack {
                    ForEach(store.hashTags, id: \.self) { tag in
                        Text(tag)
                            .font(.pretendardCaption2)
                            .foregroundColor(.gray100)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.deepSprout)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private var formattedDistance: String {
        store.distance >= 1000
        ? String(format: "%.1fkm", store.distance / 1000)
        : String(format: "%.0fm", store.distance)
    }
}

#Preview {
    StoreListItemView(store: StoreMockData.samples[0])
}

