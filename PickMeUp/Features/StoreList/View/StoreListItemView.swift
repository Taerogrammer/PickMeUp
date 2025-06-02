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
            HStack(spacing: 8) {
                MainImageView(store: store)
                ThumbnailImagesView(imageURLs: Array(store.storeImageURLs.dropFirst().prefix(2)))
            }
            .frame(maxWidth: .infinity, maxHeight: 160)

            InfoRowView(store: store)
            MetaRowView(store: store)
            HashTagsView(tags: store.hashTags)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

private struct MainImageView: View {
    let store: StorePresentable

    var body: some View {
        ZStack(alignment: .topLeading) {
            AsyncImage(url: URL(string: store.storeImageURLs.first ?? "")) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill()
                default: Color.gray30
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
                    PickchelinConcaveRibbonView()
                }
            }
            .padding(8)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ThumbnailImagesView: View {
    let imageURLs: [String]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(imageURLs, id: \.self) { url in
                AsyncImage(url: URL(string: url)) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    default: Color.gray30
                    }
                }
                .frame(width: 80, height: (160 - 4) / 2)
                .clipped()
                .cornerRadius(8)
            }
        }
    }
}

private struct InfoRowView: View {
    let store: StorePresentable

    var body: some View {
        HStack(spacing: 8) {
            Text(store.name)
                .font(.pretendardBody1)
                .foregroundColor(.gray100)

            IconText(systemName: "heart.fill", text: "\(store.pickCount)", color: .brightForsythia)
            IconText(systemName: "star.fill", text: String(format: "%.1f", store.totalRating), color: .brightForsythia)
            Text("(\(store.totalReviewCount))")
                .font(.pretendardCaption1)
                .foregroundColor(.gray60)

            Spacer()
        }
    }
}

private struct MetaRowView: View {
    let store: StorePresentable

    private var formattedDistance: String {
        store.distance >= 1000
        ? String(format: "%.1fkm", store.distance / 1000)
        : String(format: "%.0fm", store.distance)
    }

    var body: some View {
        HStack(spacing: 8) {
            IconText(systemName: "paperplane.fill", text: formattedDistance, color: .deepSprout)
            IconText(systemName: "clock", text: store.close, color: .deepSprout)
            IconText(systemName: "figure.walk", text: "\(store.totalOrderCount)회", color: .blackSprout)
        }
    }
}

private struct HashTagsView: View {
    let tags: [String]

    var body: some View {
        HStack {
            ForEach(tags, id: \.self) { tag in
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

private struct IconText: View {
    let systemName: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: systemName)
                .foregroundColor(color)
            Text(text)
                .font(.pretendardCaption1)
                .foregroundColor(.gray60)
        }
    }
}

#Preview {
    StoreListItemView(store: StoreMockData.samples[0])
}
