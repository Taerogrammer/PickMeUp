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
            .frame(maxWidth: .infinity, maxHeight: 128)

            InfoRowView(store: store)
            MetaRowView(store: store)
            HashTagsView(tags: store.hashTags)
        }
        .padding()
        .frame(height: 235)
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
            .frame(height: 128)
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

    private var paddedURLs: [String?] {
        var result = imageURLs.map { Optional($0) }
        while result.count < 2 {
            result.append(nil)
        }
        return result
    }

    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<paddedURLs.count, id: \.self) { index in
                Group {
                    if let url = paddedURLs[index],
                       let imageURL = URL(string: url) {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                Color.gray30
                            }
                        }
                    } else {
                        ZStack {
                            Color.gray30
                            VStack(spacing: 4) {
                                Image(systemName: "photo")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray60)
                                Text("No Image")
                                    .font(.caption2)
                                    .foregroundColor(.gray60)
                            }
                        }
                    }
                }
                .frame(width: 92, height: (128 - 4) / 2)
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
